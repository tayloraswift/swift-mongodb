import Durations
import Heartbeats
import MongoChannel
import NIOCore

extension Mongo
{
    /// A deployment topology monitor.
    public final
    actor Monitor
    {
        public nonisolated
        let cluster:Cluster

        private nonisolated
        let credentials:CredentialCache

        private
        var state:State
        private
        var tasks:Int
        
        init(_ seedlist:Mongo.Topology<Mongo.ConnectionPool>.Unknown,
            heartbeatInterval:Milliseconds,
            certificatePath:String?,
            application:String?,
            credentials:Mongo.Credentials?,
            resolver:DNS.Connection?,
            executor:any EventLoopGroup,
            timeout:Mongo.ConnectionTimeout)
        {
            self.credentials = .init(application: application)

            let bootstrap:ConnectionPool.Bootstrap = .init(
                heartbeatInterval: heartbeatInterval,
                certificatePath: certificatePath,
                credentials: credentials,
                cache: self.credentials,
                resolver: resolver,
                executor: executor,
                timeout: timeout)
            
            self.cluster = .init(timeout: timeout)

            self.state = .monitoring(bootstrap, .unknown(seedlist))
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

            await self.cluster.push(snapshot: snapshot)
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

            await self.cluster.push(snapshot: snapshot, sessions: sessions)
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
        while case .monitoring(let bootstrap, _) = self.state
        {
            // do not spam connections more than once per second
            async
            let cooldown:Void? = try? Task.sleep(for: .seconds(1))

            switch await self.pool(generation: generation, bootstrap: bootstrap, host: host)
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
        bootstrap:Mongo.ConnectionPool.Bootstrap,
        host:Mongo.Host) async -> ExitStatus
    {
        let deadline:Mongo.ConnectionDeadline = bootstrap.timeout.deadline(from: .now)
        
        let heartbeat:Heartbeat = .init(interval: .milliseconds(bootstrap.heartbeatInterval))
        let channel:MongoChannel
        do
        {
            channel = try await bootstrap.channel(to: host, attaching: heartbeat.heart)
        }
        catch let error
        {
            return await self.sequence(error: error, host: host)
        }

        let helloResponse:Mongo.HelloResponse

        switch await self.credentials.establish(channel,
            credentials: bootstrap.credentials,
            by: deadline)
        {
        case .failure(let error):
            async
            let checker:Void = channel.close()

            let exit:ExitStatus = await self.sequence(error: error, host: host)

            await checker

            return exit
        
        case .success(let response):
            helloResponse = response
        }
        
        let pool:Mongo.ConnectionPool = .init(generation: generation,
            signaling: heartbeat.heart,
            bootstrap: bootstrap,
            host: host)

        let exit:ExitStatus
        do
        {
            exit = try await self.check(host: host,
                initialHelloResponse: helloResponse,
                every: heartbeat,
                over: channel,
                pool: pool)
            async
            let pool:Void = pool.drain()

            await channel.close()
            await pool
        }
        catch let error
        {
            async
            let checker:Void = channel.close()
            async
            let pool:Void = pool.drain()

            exit = await self.sequence(error: error, host: host)

            await checker
            await pool
        }
        return exit
    }
    private
    func check(host:Mongo.Host, initialHelloResponse initial:Mongo.HelloResponse,
        every heartbeat:Heartbeat,
        over channel:MongoChannel,
        pool:Mongo.ConnectionPool) async throws -> ExitStatus
    {
        if  let exit:ExitStatus = await self.sequence(update: initial.update,
                sessions: initial.sessions,
                pool: pool,
                host: host)
        {
            return exit
        }
        for try await _:Void in heartbeat
        {
            let deadline:Mongo.ConnectionDeadline = pool.timeout.deadline(from: .now)
            
            let subsequent:Mongo.HelloResponse = try await channel.run(
                hello: .init(user: nil),
                by: deadline)
            if  subsequent.token != initial.token
            {
                throw Mongo.ConnectionTokenError.init(recorded: initial.token,
                    invalid: subsequent.token)
            }
            if  let exit:ExitStatus = await self.sequence(update: subsequent.update,
                    sessions: subsequent.sessions,
                    pool: pool,
                    host: host)
            {
                return exit
            }
        }
        //  a variety of errors can happen while checking a server.
        //  but if the checker stops without an error, that means
        //  that monitoring was explicitly halted. so we never try
        //  to reconnect on this path.
        return .stop
    }
}
