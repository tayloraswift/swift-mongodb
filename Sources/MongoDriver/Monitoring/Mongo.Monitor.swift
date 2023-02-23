import Durations
import Heartbeats
import NIOCore
import OnlineCDF

extension Mongo
{
    /// A deployment topology monitor.
    final
    actor Monitor
    {
        private nonisolated
        let deployment:Deployment

        private
        var state:State
        private
        var tasks:Int
        
        init(_ seedlist:Topology<ConnectionPool>.Unknown,
            deployment:Deployment,
            connector:MonitorConnector)
        {
            self.deployment = deployment

            self.state = .monitoring(connector, .unknown(seedlist))
            self.tasks = 0

            for host:Mongo.Host in seedlist.ghosts.keys
            {
                self.monitor(host: host)
            }
        }

        func stop() async
        {
            guard case .monitoring(_, var topology) = self.state
            else
            {
                fatalError("unreachable (stopping monitor that is not running!)")
            }
            guard self.tasks != 0
            else
            {
                self.state = .stopping(nil)
                return
            }
            await withCheckedContinuation
            {
                topology.removeAll()
                self.state = .stopping($0)
            }
        }

        deinit
        {
            guard case .stopping(nil) = self.state
            else
            {
                fatalError("unreachable (deinitialized monitor that has not been stopped!)")
            }
            guard self.tasks == 0
            else
            {
                fatalError("unreachable (deinitialized monitor while tasks are still running!)")
            }
        }
    }
}
extension Mongo.Monitor
{
    private nonisolated
    var timeout:Mongo.ConnectionTimeout
    {
        self.deployment.timeout
    }
    private nonisolated
    var logger:Mongo.Logger?
    {
        self.deployment.logger
    }
}
extension Mongo.Monitor
{
    private
    func sequence(error:any Error, host:Mongo.Host) async -> ExitStatus
    {
        if case .monitoring(let bootstrap, var topology) = self.state
        {
            self.state = .stopping(nil)

            let accepted:Bool = topology.combine(error: error, host: host)
            let snapshot:Mongo.Servers = .init(from: topology,
                heartbeatInterval: bootstrap.heartbeatInterval)

            self.state = .monitoring(bootstrap, topology)

            await self.deployment.push(snapshot: snapshot)
            return accepted ? .reconnect : .stop
        }
        else
        {
            return .stop
        }
    }
    private
    func sequence(update:Mongo.TopologyUpdate?,
        sessions:Mongo.LogicalSessions,
        pool:Mongo.ConnectionPool,
        host:Mongo.Host) async -> ExitStatus?
    {
        if case .monitoring(let bootstrap, var topology) = self.state
        {
            self.state = .stopping(nil)

            let accepted:Bool = topology.combine(update: update, host: host, pool: pool,
                add: self.monitor(host:))
            let snapshot:Mongo.Servers = .init(from: topology,
                heartbeatInterval: bootstrap.heartbeatInterval)

            self.state = .monitoring(bootstrap, topology)

            await self.deployment.push(snapshot: snapshot, sessions: sessions)
            return accepted ? nil : .stop
        }
        else
        {
            return .stop
        }
    }
}
extension Mongo.Monitor
{
    private nonisolated
    func monitor(host:Mongo.Host)
    {
        let _:Task<Void, Never> = .init
        {
            await self.monitor(host: host)
        }
    }
    private
    func monitor(host:Mongo.Host) async
    {
        do
        {
            self.tasks += 1
        }
        defer
        {
            self.tasks -= 1

            if  self.tasks == 0,
                case .stopping(let continuation?) = self.state
            {
                continuation.resume()
                self.state = .stopping(nil)
            }
        }

        var generation:UInt = 0
        while case .monitoring(let connector, _) = self.state
        {
            // do not spam connections more than once per second
            async
            let cooldown:Void? = try? Task.sleep(for: .seconds(1))

            switch await self.pool(generation: generation, connector: connector, host: host)
            {
            case .reconnect:
                generation += 1
                await cooldown
                continue
            
            case .stop:
                return
            }
        }
    }
    private
    func pool(generation:UInt,
        connector:Mongo.MonitorConnector,
        host:Mongo.Host) async -> ExitStatus
    {
        let deadline:Mongo.ConnectionDeadline = self.timeout.deadline(from: .now)

        let connection:Mongo.MonitorConnection
        do
        {
            connection = try await connector.connect(to: host)
        }
        catch let error
        {
            return await self.sequence(error: error, host: host)
        }

        //  '''
        //  Drivers MUST NOT authenticate on sockets used for monitoring nor
        //  include SCRAM mechanism negotiation (i.e. saslSupportedMechs), as
        //  doing so would make monitoring checks more expensive for the server.
        //  '''
        let hello:HelloResult
        do
        {
            hello = try await connection.run(hello: .init(
                    client: connector.client,
                    user: nil),
                by: deadline)
        }
        catch let error
        {
            async
            let checker:Void = connection.close()

            let exit:ExitStatus = await self.sequence(error: error, host: host)

            await checker

            return exit
        }
        
        let pool:Mongo.ConnectionPool = .init(generation: generation,
            signaling: connection.heartbeat.heart,
            connector: connector,
            timeout: self.timeout,
            logger: self.logger,
            host: host)

        let exit:ExitStatus
        do
        {
            exit = try await self.check(host: host,
                initialHello: hello,
                over: connection,
                pool: pool)
            async
            let pool:Void = pool.drain(because: .init())

            await connection.close()
            await pool
        }
        catch let error
        {
            async
            let checker:Void = connection.close()
            async
            let pool:Void = pool.drain(because: .init(because: error))

            exit = await self.sequence(error: error, host: host)

            await checker
            await pool
        }
        return exit
    }
    private
    func check(host:Mongo.Host, initialHello initial:HelloResult,
        over connection:Mongo.MonitorConnection,
        pool:Mongo.ConnectionPool) async throws -> ExitStatus
    {
        if  let exit:ExitStatus = await self.sequence(update: initial.response.update,
                sessions: initial.response.sessions,
                pool: pool,
                host: host)
        {
            return exit
        }

        var latency:Mongo.LatencyCDF = .init(seed: initial.latency, notifying: pool)

        for try await _:Void in connection.heartbeat
        {
            let deadline:Mongo.ConnectionDeadline = self.timeout.deadline(from: .now)
            
            let subsequent:HelloResult = try await connection.run(
                hello: .init(user: nil),
                by: deadline)
            if  subsequent.response.token != initial.response.token
            {
                throw Mongo.ConnectionTokenError.init(recorded: initial.response.token,
                    invalid: subsequent.response.token)
            }
            if  let exit:ExitStatus = await self.sequence(update: subsequent.response.update,
                    sessions: subsequent.response.sessions,
                    pool: pool,
                    host: host)
            {
                return exit
            }

            latency.insert(subsequent.latency, notifying: pool)
        }
        //  a variety of errors can happen while checking a server.
        //  but if the checker stops without an error, that means
        //  that monitoring was explicitly halted. so we never try
        //  to reconnect on this path.
        return .stop
    }
}
