import BSON
import Heartbeats
import MongoWire
import NIOCore

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
        var awaiting:[ServerSelector: [CheckedContinuation<SessionContext, Never>]]
        private 
        var sessions:SessionPool
        private
        var sessionTimeout:Mongo.Minutes?
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
            self.sessionTimeout = nil
            self.topology = .unknown(seedlist)
        }

        deinit
        {
            guard self.awaiting.isEmpty
            else
            {
                fatalError("unreachable: deinitialized while continuations are awaiting!")
            }
            guard self.sessions.claimed.isEmpty
            else
            {
                fatalError("unreachable: draining session pool while sessions are still in use!")
            }
            
            var command:EndSessions? = .init(.init(self.sessions.available.keys))

            self.topology.removeAll(throwing: &command)

            if let command:EndSessions
            {
                print("warning: could not throw 'EndSessions' \(command.sessions)")
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
    func update(host:Mongo.Host, connection:Mongo.Connection,
        metadata:Mongo.ServerMetadata) -> Void?
    {
        self.topology.update(host: host, connection: connection, metadata: metadata.type,
            monitor: self.monitor(host:))
            .map
        {
            // update session timeout
            let timeout:Mongo.Minutes = min(metadata.sessionTimeout,
                self.sessionTimeout ?? metadata.sessionTimeout)

            self.sessionTimeout = timeout

            // succeed any tasks awaiting connections
            if      let connection:Mongo.Connection = self.topology.master
            {
                for continuation:CheckedContinuation<Mongo.SessionContext, Never>
                    in self.awaiting.values.joined()
                {
                    continuation.resume(returning: .init(connection: connection, 
                        timeout: timeout))
                }
                self.awaiting = [:]
            }
            else if let connection:Mongo.Connection = self.topology.any
            {
                for continuation:CheckedContinuation<Mongo.SessionContext, Never>
                    in self.awaiting.removeValue(forKey: .any) ?? []
                {
                    continuation.resume(returning: .init(connection: connection, 
                        timeout: timeout))
                }
            }
        }
    }
    func clear(host:Mongo.Host, status:(any Error)?) -> Void?
    {
        self.topology.clear(host: host, status: status)
    }

    private nonisolated
    func monitor(host:Mongo.Host)
    {
        let monitor:Mongo.ConnectionMonitor = .init(self)
        let _:Task<Void, Never> = .init
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
    // public nonisolated
    // func session(
    //     for command:(some MongoImplicitSessionCommand).Type) async throws -> Mongo.Session
    // {
    //     try await self.session(on: command.node)
    // }
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
    // public nonisolated
    // func session(on instance:Mongo.ServerSelector) async throws -> Mongo.Session
    // {
    //     let connection:Mongo.Connection = try await self.connection(to: instance)
    //     return .init(connection: connection, manager: .init(
    //         id: await self.startSession(),
    //         cluster: self))
    // }


}
extension Mongo.Deployment
{
    func session(on selector:Mongo.ServerSelector) async ->
    (
        context:Mongo.SessionContext,
        metadata:Mongo.SessionMetadata
    )
    {
        let context:Mongo.SessionContext
        if  let connection:Mongo.Connection = self.topology[selector],
            let timeout:Mongo.Minutes = self.sessionTimeout
        {
            context = .init(connection: connection, timeout: timeout)
        }
        else
        {
            context = await withCheckedContinuation
            {
                self.awaiting[selector, default: []].append($0)
            }
        }
        return (context, self.sessions.checkout(context: context))
    }

    func checkin(session:Mongo.SessionMetadata)
    {
        self.sessions.checkin(session)
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
        try await Mongo.MutableSession.init(on: self).run(command: command)
    }
    /// Runs a session command against the specified database,
    /// sending the command to an appropriate cluster member for its type.
    public nonisolated
    func run<Command>(command:Command, 
        against database:Mongo.Database) async throws -> Command.Response
        where Command:MongoImplicitSessionCommand & MongoDatabaseCommand
    {    
        try await Mongo.MutableSession.init(on: self).run(command: command, against: database)
    }
}
