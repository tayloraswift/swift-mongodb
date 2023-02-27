import Durations
import NIOCore

extension Mongo
{
    /// A deployment topology monitor.
    final
    actor Monitor
    {
        private nonisolated
        let deployment:Deployment

        /// The monitoring interval, in milliseconds.
        private nonisolated
        let interval:Milliseconds

        private
        var phase:Phase
        private
        var tasks:Int
        
        init(_ seedlist:Topology<Mongo.TopologyMonitor.Canary>.Unknown,
            connectionPoolSettings:ConnectionPool.Settings,
            connectorFactory:ConnectorFactory,
            authenticator:Authenticator,
            deployment:Deployment,
            interval:Milliseconds)
        {
            self.deployment = deployment
            self.interval = interval

            self.phase = .active(.init(connectionPoolSettings: connectionPoolSettings,
                connectorFactory: connectorFactory,
                authenticator: authenticator,
                topology: .unknown(seedlist)))
            
            self.tasks = 0

            for host:Mongo.Host in seedlist.ghosts.keys
            {
                self.monitor(host: host)
            }
        }

        func stop() async
        {
            guard case .active = self.phase
            else
            {
                fatalError("unreachable (stopping monitor that is not running!)")
            }
            guard self.tasks != 0
            else
            {
                self.phase = .stopped
                return
            }
            await withCheckedContinuation
            {
                //  Overwriting the topology in ``state`` will also release
                //  all the monitoring tasks owned by the topology.
                self.phase = .stopping($0)
            }
        }

        deinit
        {
            guard case .stopped = self.phase
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
                case .stopping(let continuation) = self.phase
            {
                continuation.resume()
                self.phase = .stopped
            }
        }

        var generation:UInt = 0
        while case .active(let state) = self.phase
        {
            // do not spam connections more than once per second
            async
            let cooldown:Void? = try? Task.sleep(for: .seconds(1))

            switch await self.pool(connectorFactory: state.connectorFactory,
                authenticator: state.authenticator,
                generation: generation,
                settings: state.connectionPoolSettings,
                host: host)
            {
            case .refill:
                generation += 1
                await cooldown
                continue
            
            case .none:
                return
            }
        }
    }
    private
    func pool(connectorFactory:Mongo.ConnectorFactory,
        authenticator:Mongo.Authenticator,
        generation:UInt,
        settings:Mongo.ConnectionPool.Settings,
        host:Mongo.Host) async -> RefillPolicy
    {
        let connector:Mongo.Connector<Never?> = connectorFactory(authenticator: nil,
            timeout: self.timeout,
            host: host)

        let updates:AsyncThrowingStream<Mongo.TopologyMonitor.Update, any Error>
        let tasks:Mongo.MonitorTasks

        do
        {
            (tasks, updates) = try await connector.monitors(interval: self.interval)
        }
        catch let error
        {
            switch await self.combine(error: error, host: host)
            {
            case .accepted, .dropped:
                return .refill
            case .rejected:
                return .none
            }
        }
        
        let pool:Mongo.ConnectionPool = tasks.pool(generation: generation,
            settings: settings,
            logger: self.logger)
        
        async
        let _:Void = tasks.start(connectionTimeout: self.timeout,
            connectorFactory: connectorFactory,
            authenticator: authenticator,
            pool: pool)

        return await self.iterate(updates: updates, host: host)
    }
    
    private
    func iterate(updates:AsyncThrowingStream<Mongo.TopologyMonitor.Update, any Error>,
        host:Mongo.Host) async -> RefillPolicy
    {
        do
        {
            for try await update:Mongo.TopologyMonitor.Update in updates
            {
                switch await self.combine(update: update, host: host)
                {
                case .accepted:
                    continue
                
                case .dropped:
                    return .refill
                
                case .rejected:
                    return .none
                }
            }
            switch await self.combine(error: nil, host: host)
            {
            case .accepted, .dropped:
                return .refill
            
            case .rejected:
                return .none
            }
        }
        catch let error
        {
            switch await self.combine(error: error, host: host)
            {
            case .accepted, .dropped:
                return .refill
            
            case .rejected:
                return .none
            }
        }
    }

    private
    func combine(update:Mongo.TopologyMonitor.Update,
        host:Mongo.Host) async -> Mongo.TopologyUpdateResult
    {
        guard case .active(var state) = self.phase
        else
        {
            return .rejected
        }
        
        self.phase = .stopped

        let result:Mongo.TopologyUpdateResult = state.topology.combine(update: update.topology,
            owner: update.canary,
            host: host,
            add: self.monitor(host:))
        
        let snapshot:Mongo.Servers = .init(from: state.topology,
            heartbeatInterval: self.interval)

        self.phase = .active(state)

        await self.deployment.push(snapshot: snapshot, sessions: update.sessions)
        return result
    }

    private
    func combine(error:(any Error)?, host:Mongo.Host) async -> Mongo.TopologyUpdateResult
    {
        guard case .active(var state) = self.phase
        else
        {
            return .rejected
        }

        self.phase = .stopped

        let result:Mongo.TopologyUpdateResult = state.topology.combine(error: error,
            host: host)

        let snapshot:Mongo.Servers = .init(from: state.topology,
            heartbeatInterval: self.interval)

        self.phase = .active(state)

        await self.deployment.push(snapshot: snapshot)
        return result
    }
}
