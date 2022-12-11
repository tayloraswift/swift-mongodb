import BSON
import Heartbeats
import MongoWire
import NIOCore

extension Mongo
{
    actor Deployment
    {
        let credentials:Credentials?

        private
        let settings:ConnectionSettings
        private 
        let resolver:DNS.Connection?,
            group:any EventLoopGroup

        private
        var sessionTimeout:Mongo.Minutes?
        private
        var topology:Topology
        private
        var awaiting:[ServerSelector: [CheckedContinuation<SessionMedium, Never>]]

        init(credentials:Credentials?,
            settings:ConnectionSettings,
            resolver:DNS.Connection?,
            group:any EventLoopGroup,
            seeds:Set<Mongo.Host>) 
        {
            self.credentials = credentials
            self.settings = settings
            self.resolver = resolver
            self.group = group

            self.sessionTimeout = nil
            self.topology = .unknown(.init(hosts: seeds))
            self.awaiting = [:]

            for host:Mongo.Host in seeds
            {
                self.monitor(host)
            }
        }

        deinit
        {
            guard self.awaiting.isEmpty
            else
            {
                fatalError("unreachable: deinitialized while continuations are awaiting!")
            }

            print("deinitialized deployment")
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
}

extension Mongo.Deployment
{
    func terminate()
    {
        self.topology.terminate()
    }

    private
    func clear(host:Mongo.Host, status:(any Error)?) -> Void?
    {
        self.topology.clear(host: host, status: status)
    }
    private
    func update(host:Mongo.Host, connection:Mongo.Connection,
        metadata:Mongo.ServerMetadata) -> Void?
    {
        self.topology.update(host: host, connection: connection, metadata: metadata.type,
            monitor: self.monitor(_:))
            .map
        {
            // update session timeout
            let timeout:Mongo.Minutes = min(metadata.sessionTimeout,
                self.sessionTimeout ?? metadata.sessionTimeout)

            self.sessionTimeout = timeout

            // succeed any tasks awaiting connections
            if      let connection:Mongo.Connection = self.topology.master
            {
                for continuation:CheckedContinuation<Mongo.SessionMedium, Never>
                    in self.awaiting.values.joined()
                {
                    continuation.resume(returning: .init(connection: connection, 
                        timeout: timeout))
                }
                self.awaiting = [:]
            }
            else if let connection:Mongo.Connection = self.topology.any
            {
                for continuation:CheckedContinuation<Mongo.SessionMedium, Never>
                    in self.awaiting.removeValue(forKey: .any) ?? []
                {
                    continuation.resume(returning: .init(connection: connection, 
                        timeout: timeout))
                }
            }
        }
    }
}
extension Mongo.Deployment
{
    private nonisolated
    func monitor(_ host:Mongo.Host)
    {
        let _:Task<Void, Never> = .init
        {
            await self.monitor(host)
        }
    }
    private
    func monitor(_ host:Mongo.Host) async
    {
        while true
        {
            // do not spam connections more than once per second
            async
            let cooldown:Void = try await Task.sleep(for: .seconds(1))
            let status:(any Error)?
            
            do
            {
                try await self.connect(to: host)
                status = nil
            }
            catch let error
            {
                status = error
                print("error:", error)
            }

            if case ()? = self.clear(host: host, status: status)
            {
                try? await cooldown
            }
            else
            {
                //  host was removed.
                break
            }
        }
    }
    private
    func connect(to host:Mongo.Host) async throws
    {
        let heartbeat:Heartbeat = .init(interval: .milliseconds(1000))
        let connection:Mongo.Connection = try await .connect(to: host, 
            settings: self.settings,
            resolver: self.resolver,
            heart: heartbeat.heart,
            group: self.group)
        
        defer
        {
            // will be a no-op if the connection closed spontaneously,
            // terminating the stream of heartbeats
            connection.close()
        }

        //  initial login, performs auth (if using auth).
        let initial:Mongo.Hello.Response = try await connection.establish(
            credentials: self.credentials)
        
        self.update(host: host, connection: connection, metadata: initial.metadata)

        for try await _:Void in heartbeat
        {
            let updated:Mongo.Hello.Response = try await connection.run(
                command: .init(user: nil))
            if  updated.token == initial.token
            {
                self.update(host: host, connection: connection, metadata: updated.metadata)
            }
            else
            {
                throw Mongo.ConnectionTokenError.init(recorded: initial.token,
                    invalid: updated.token)
            }
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

    func medium(selector:Mongo.ServerSelector) async -> Mongo.SessionMedium
    {
        if  let connection:Mongo.Connection = self.topology[selector],
            let timeout:Mongo.Minutes = self.sessionTimeout
        {
            return .init(connection: connection, timeout: timeout)
        }
        else
        {
            return await withCheckedContinuation
            {
                self.awaiting[selector, default: []].append($0)
            }
        }
    }

    /// Sends an ``EndSessions`` command ending the given sessions to an
    /// appropriate server for this deployment’s topology, and awaits its
    /// response. Returns [`nil`]() if there were no suitable servers to
    /// send the command to.
    func end(sessions:__owned [Mongo.SessionIdentifier]) async throws -> Void?
    {
        let command:Mongo.EndSessions = .init(sessions)
        switch self.topology
        {
        case .terminated, .unknown(_):
            return nil
        
        case .single(let topology):
            return try await topology.master?.run(command: command)
        
        case .sharded(let topology):
            //  ``EndSessions`` can be sent to any `mongos`.
            return try await topology.any?.run(command: command)
        
        case .replicated(let topology):
            //  ``EndSessions`` should be sent to the primary if available,
            //  or any available secondary otherwise.
            //  the spec says we should send the command *once*, and ignore
            //  all errors, so we will not retry the command on a secondary
            //  if it failed on the primary.
            return try await (topology.master ?? topology.any)?.run(command: command)
        }
    }
}
