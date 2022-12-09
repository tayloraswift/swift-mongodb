import BSON
import Heartbeats
import MongoWire
import NIOCore

// public
// protocol MongoTopology
// {
//     var sessionTimeout:Mongo.Minutes? { get }

//     mutating
//     func scan() async throws

//     mutating 
//     func connection(to selector:Mongo.ServerSelector,
//         on group:some EventLoopGroup) async throws -> Mongo.Connection
// }

// extension Mongo
// {
//     struct Standalone
//     {
//         let host:Host
//         let settings:ConnectionSettings

//         var connection:Connection?
//         var sessionTimeout:Minutes?

//         init(host:Host, settings:ConnectionSettings)
//         {
//             self.host = host
//             self.settings = settings
//             self.connection = nil
//             self.sessionTimeout = nil
//         }
//     }
// }
// extension Mongo.Standalone:MongoTopology
// {
//     mutating
//     func scan() async throws
//     {
//         guard let connection:Mongo.Connection = self.connection
//         else
//         {
//             return
//         }

//         do
//         {
//             let server:Mongo.Server = try await connection.run(command: .init(user: nil))
//             self.sessionTimeout = server.logicalSessionTimeoutMinutes
//         }
//         catch let error
//         {
//             connection.close()
//             self.connection = nil
//             self.sessionTimeout = nil
//             throw error
//         }
//     }

//     mutating
//     func connection(to _:Mongo.ServerSelector,
//         on group:any EventLoopGroup) async throws -> Mongo.Connection
//     {
//         if let connection:Mongo.Connection = self.connection
//         {
//             return connection
//         }

//         let connection:Mongo.Connection = try await .connect(to: host,
//             settings: self.settings,
//             group: group)
        
//         let server:Mongo.Server
//         do
//         {
//             server = try await connection.establish(credentials: self.settings.credentials)
//         }
//         catch let error
//         {
//             connection.close()
//             throw error
//         }

//         self.connection = connection
//         self.sessionTimeout = server.logicalSessionTimeoutMinutes
//     }
// }


// extension Mongo
// {
//     struct _Cluster<Member>
//     {
//         private
//         var monitored:[Host: ConnectionState<Member>]
//     }
// }
// extension Mongo._Cluster
// {
//     subscript(host:Mongo.Host) -> MemberState
//     {
//         get
//         {
//             self.monitored[host].map(MemberState.monitored(_:)) ?? .unmonitored
//         }
//         _modify
//         {
//             if  let index:Dictionary<Mongo.Host, Mongo.ConnectionState<Member>>.Index =
//                     self.monitored.index(forKey: host)
//             {
//                 var state:MemberState = .monitored(self.monitored.values[index])
//                 yield &state
//                 switch state
//                 {
//                 case .monitored(let monitored):
//                     self.monitored.values[index] = monitored
                
//                 case .unmonitored:
//                     self.monitored.remove(at: index)
//                 }
//             }
//             else
//             {
//                 var state:MemberState = .unmonitored
//                 yield &state
//                 switch state
//                 {
//                 case .monitored(let monitored):
//                     // rehashes!
//                     self.monitored.updateValue(monitored, forKey: host)
                
//                 case .unmonitored:
//                     break
//                 }
//             }
//         }
//     }
// }

extension Mongo
{
    @available(*, deprecated, renamed: "Deployment")
    public
    typealias Cluster = Deployment

    public 
    actor Deployment
    {
        let credentials:Credentials?

        private
        let settings:ConnectionSettings
        private 
        let resolver:DNS.Connection?,
            group:any EventLoopGroup

        private
        var awaiting:[ServerSelector: [CheckedContinuation<Connection, Never>]]
        private 
        var sessions:SessionPool
        private
        var topology:Topology

        private 
        init(credentials:Credentials?, seedlist:Seedlist,
            settings:ConnectionSettings,
            resolver:DNS.Connection?,
            group:any EventLoopGroup) 
        {
            self.credentials = credentials
            self.settings = settings
            self.resolver = resolver
            self.group = group

            self.awaiting = [:]
            self.sessions = .init()
            self.topology = .unknown(seedlist)
        }

        deinit
        {
            let sessions:[Session.ID] = self.sessions.drain()
            Task.init
            {
                [connections, sessions] in

                // find a connection to a primary, if available
                var connection:Connection? = nil
                for candidate:Connection in connections.values
                {
                    connection = candidate

                    if candidate.server.isWritablePrimary
                    {
                        break
                    }
                }
                if let connection:Connection
                {
                    print("attempting to end sessions:", sessions)
                    do
                    {
                        let message:Mongo.EndSessions.Response = try await connection.run(
                            command: .init(sessions))
                        print(message)
                    }
                    catch let error
                    {
                        print(error)
                    }
                }
                for connection:Connection in connections.values
                {
                    connection.close()
                }
            }
        }
    }
}

extension Mongo.Deployment
{
    /// Opens a connection to the requested host with the settings
    /// stored in this instance. This method only creates the connection,
    /// it does not register the connection, perform any handshakes or
    /// authentication, or start any monitoring.
    func connect(to host:Mongo.Host, heart:Heart) async throws -> Mongo.Connection
    {
        try await .connect(to: host, 
            settings: self.settings,
            resolver: self.resolver,
            heart: heart,
            group: self.group)
    }
    func update(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Server) -> Void?
    {
        self.topology.update(host: host, connection: connection,
            metadata: metadata)
        {
            self.monitor(host: $0)
        }
    }
    func clear(host:Mongo.Host, status:(any Error)?) -> Void?
    {
        self.topology.clear(host: host, status: status)
    }

    @discardableResult
    private nonisolated
    func monitor(host:Mongo.Host) -> Task<Void, Never>
    {
        let monitor:Mongo.ConnectionMonitor = .init(self)
        return .init
        {
            await monitor.monitor(host)
        }
    }
}
extension Mongo.Deployment
{
    // public 
    // init(settings:Mongo.ConnectionSettings,
    //     discovery:Mongo.Discovery,
    //     group:any EventLoopGroup) async throws 
    // {
    //     switch discovery
    //     {
    //     case .standard(servers: let servers):
    //         try await self.init(settings: settings, seeds: servers, group: group)
        
    //     case .seeded(srv: _, nameserver: nil):
    //         fatalError("unimplemented")
        
    //     case .seeded(srv: _, nameserver: _?):
    //         fatalError("unimplemented")
    //     }
    // }
    public 
    init(credentials:Mongo.Credentials?, seedlist:Set<Mongo.Host>,
        settings:Mongo.ConnectionSettings,
        group:any EventLoopGroup) async throws 
    {
        self.init(credentials: credentials, seedlist: .init(hosts: seedlist),
            settings: settings,
            resolver: nil,
            group: group)
        
        for host:Mongo.Host in seedlist
        {
            self.monitor(host: host)
        }
    }
}
extension Mongo.Deployment
{
    public nonisolated
    func session(
        for command:(some MongoImplicitSessionCommand).Type) async throws -> Mongo.Session
    {
        try await self.session(on: command.node)
    }
    /// Attempts to obtain a connection to a cluster member matching the given
    /// instance selector, and if successful, generates and attaches a ``Session/ID``
    /// to it that the driver believes is not currently in use.
    ///
    /// Starting a MongoDB session involves no communication with the server;
    /// clients and servers simply use the session identifiers as a means of
    /// organizing operations.
    ///
    /// Because the session identifier is random and generated locally, there
    /// is a (small) chance that it may collide with a session identifier
    /// generated by a previous application run, if the application exited
    /// abnormally. UUID collisions are exceedingly rare, and the driver always
    /// attempts to clear sessions it generated on shutdown, so this is an
    /// extremely unlikely scenario.
    ///
    /// The driver will attempt to re-use session identifiers that are no
    /// longer in use if it believes the server has not yet released the
    /// session descriptor on its end, to minimize the number of active server
    /// sessions at a given time.
    public nonisolated
    func session(on instance:Mongo.ServerSelector) async throws -> Mongo.Session
    {
        let connection:Mongo.Connection = try await self.connection(to: instance)
        return .init(connection: connection, manager: .init(
            id: await self.startSession(),
            cluster: self))
    }

    private
    func startSession() -> Mongo.Session.ID
    {
        self.sessions.checkout()
    }

    func extendSession(_ session:Mongo.Session.ID, timeout:ContinuousClock.Instant)
    {
        self.sessions.extend(session, timeout: timeout)
    }
    func releaseSession(_ session:Mongo.Session.ID)
    {
        self.sessions.checkin(session)
    }
}
extension Mongo.Deployment
{
    /// Obtains a connection to a cluster member matching the given instance selector.
    func connection(to selector:Mongo.ServerSelector) async throws -> Mongo.Connection
    {
        // look for existing connections
        for (_, connection):(Mongo.Host, Mongo.Connection) in self.connections
            where selector ~= connection.server
        {
            return connection
        }
        // form new connections
        var errors:[(host:Mongo.Host, error:any Error)] = []
        while let host:Mongo.Host = self.hosts.first
        {
            self.hosts.removeFirst()
            do
            {
                let connection:Mongo.Connection = try await self.connect(to: host)
                if selector ~= connection.server
                {
                    return connection
                }
            }
            catch let error
            {
                errors.append((host, error))
            }
        }
        throw Mongo.ConnectionErrors.init(selector: selector, errors: errors)
    }

    private
    func connect(to host:Mongo.Host) async throws -> Mongo.Connection
    {
        let connection:Mongo.Connection = try await .connect(to: host,
            settings: self.settings,
            resolver: self.dns,
            group: group)
            
        self.didOpenConnection(connection, to: host)

        connection.closeFuture.whenComplete 
        { 
            [weak self, host] _ in

            if let deployment:Mongo.Deployment = self 
            { 
                Task.init
                {
                    await deployment.didCloseConnection(to: host)
                }
            }
        }

        return connection
    }
    private
    func didOpenConnection(_ connection:Mongo.Connection, to host:Mongo.Host)
    {
        guard case nil = self.connections.updateValue(connection, forKey: host)
        else
        {
            fatalError("unreachable: added a connection to a pool more than once!")
        }

        if let set:Mongo.Server.ReplicaSet = connection.server.set
        {
            for host:Mongo.Host in [set.hosts, set.passives].joined()
                where !self.connections.keys.contains(host)
            {
                self.hosts.append(host)
            }
        }
    }
    private
    func didCloseConnection(to host:Mongo.Host)
    {
        if case _? = self.connections.removeValue(forKey: host)
        {
            // put the host back in the discovery queue
            self.hosts.append(host)
        }
        else
        {
            fatalError("unreachable: disconnected from unknown host '\(host)'")
        }
    }
}

extension Mongo.Deployment
{
    /// Runs a session command against the ``Mongo/Database/.admin`` database,
    /// sending the command to an appropriate cluster member for its type.
    public nonisolated
    func run<Command>(command:Command) async throws -> Command.Response
        where Command:MongoImplicitSessionCommand
    {    
        try await self.session(for: Command.self).run(command: command)
    }
    /// Runs a session command against the specified database,
    /// sending the command to an appropriate cluster member for its type.
    public nonisolated
    func run<Command>(command:Command, 
        against database:Mongo.Database) async throws -> Command.Response
        where Command:MongoImplicitSessionCommand & MongoDatabaseCommand
    {    
        try await self.session(for: Command.self).run(command: command,
            against: database)
    }
}
