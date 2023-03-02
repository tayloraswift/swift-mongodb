import Durations
import NIOCore

extension Mongo
{
    /// A deployment topology monitor.
    final
    actor MonitorPool
    {
        private nonisolated
        let deployment:Deployment

        private nonisolated
        let connectionPoolSettings:Mongo.ConnectionPoolSettings,
            connectorFactory:Mongo.ConnectorFactory,
            authenticator:Mongo.Authenticator

        private
        var observers:Observers
        private
        var topology:TopologyModel?

        private
        var tasks:Int
        
        init(connectionPoolSettings:ConnectionPoolSettings,
            connectorFactory:ConnectorFactory,
            authenticator:Authenticator,
            deployment:Deployment)
        {
            self.deployment = deployment
            
            self.connectionPoolSettings = connectionPoolSettings
            self.connectorFactory = connectorFactory
            self.authenticator = authenticator
            
            self.observers = .none
            self.topology = nil
            self.tasks = 0
        }

        deinit
        {
            guard self.tasks == 0
            else
            {
                fatalError("unreachable (deinitialized monitor while tasks are still running!)")
            }
        }
    }
}
extension Mongo.MonitorPool
{
    func start(interval:Milliseconds, seedlist:Set<Mongo.Host>) async
    {
        await withTaskCancellationHandler
        {
            await withCheckedContinuation
            {
                self.topology = .init(interval: interval, seedlist: seedlist)
                self.observers.append($0)

                for host:Mongo.Host in seedlist
                {
                    self.monitor(host: host)
                }
            }
        }
        onCancel:
        {
            let _:Task<Void, Never> = .init
            {
                await self.drain()
            }
        }
    }
    private
    func drain()
    {
        defer
        {
            self.topology = nil
        }
        if self.tasks == 0
        {
            self.observers.resume()
        }
    }
}
extension Mongo.MonitorPool
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

            if case nil = self.topology, self.tasks == 0
            {
                self.observers.resume()
            }
        }

        var generation:UInt = 0
        while let interval:Milliseconds = self.topology?.interval
        {
            // do not spam connections more than once per second
            async
            let cooldown:Void = Task.sleep(for: .seconds(1))

            switch await self.monitor(host: host, generation: generation, interval: interval)
            {
            case .replace:
                generation += 1
                try? await cooldown
                continue
            
            case .none:
                return
            }
        }
    }
    private
    func monitor(host:Mongo.Host, generation:UInt, interval:Milliseconds) async -> Replacement
    {
        let connectionTimeout:Milliseconds = self.deployment.timeout.default
        let connector:Mongo.Connector<Never?> = self.connectorFactory(authenticator: nil,
            timeout: connectionTimeout,
            host: host)

        let services:Mongo.Services

        do
        {
            services = try await connector.connect(interval: interval)
        }
        catch let error
        {
            switch await self.combine(error: error, host: host)
            {
            case .accepted, .dropped:
                return .replace
            case .rejected:
                return .none
            }
        }
        
        var monitor:AsyncThrowingStream<Update, any Error>.Continuation?
        let updates:AsyncThrowingStream<Update, any Error> = .init
        {
            monitor = $0
        }
        guard let monitor:AsyncThrowingStream<Update, any Error>.Continuation
        else
        {
            fatalError("unreachable")
        }

        return await withTaskGroup(of: Void.self)
        {
            (tasks:inout TaskGroup<Void>) in

            let services:AsyncStream<Mongo.Service> = .init(
                bufferingPolicy: .bufferingOldest(1))
            {
                let pool:Mongo.ConnectionPool = .init(alongside: .init($0),
                    connectionTimeout: connectionTimeout,
                    connectorFactory: self.connectorFactory,
                    authenticator: self.authenticator,
                    generation: generation,
                    settings: self.connectionPoolSettings,
                    logger: self.deployment.logger,
                    host: host)
                
                pool.set(latency: services.handshake.latency)

                monitor.yield(.init(
                    topology: services.handshake.response.topologyUpdate,
                    sessions: services.handshake.response.sessions,
                    canary: .init(pool: pool)))

                tasks.addTask
                {
                    await services.listener.start(alongside: pool, updating: monitor)
                }
                tasks.addTask
                {
                    await services.sampler.start(alongside: pool)
                }
                tasks.addTask
                {
                    await pool.start()
                }
            }

            async
            let replacement:Replacement = self.subscribe(to: updates,
                generation: generation,
                host: host)
            
            for await _:Mongo.Service in services
            {
                break
            }

            tasks.cancelAll()

            return await replacement
        }
    }

    private
    func subscribe(
        to updates:AsyncThrowingStream<Update, any Error>,
        generation:UInt,
        host:Mongo.Host) async -> Replacement
    {
        let status:(any Error)?
        do
        {
            for try await update:Update in updates
            {
                switch await self.combine(update: update, host: host)
                {
                case .accepted:
                    continue
                
                case .dropped:
                    return .replace
                
                case .rejected:
                    return .none
                }
            }
            status = nil
        }
        catch let error
        {
            status = error
        }

        switch await self.combine(error: status, host: host)
        {
        case .accepted, .dropped:
            return .replace
        
        case .rejected:
            return .none
        }
    }

    private
    func combine(update:__owned Update, host:Mongo.Host) async -> Mongo.TopologyUpdateResult
    {
        switch self.topology?.combine(update: update.topology,
            owner: update.canary,
            host: host,
            add: self.monitor(host:))
        {
        case nil:
            return .rejected

        case (let result, let model)?:
            await self.deployment.push(snapshot: model, sessions: update.sessions)
            return result
        }
    }

    private
    func combine(error:(any Error)?, host:Mongo.Host) async -> Mongo.TopologyUpdateResult
    {
        switch self.topology?.combine(error: error, host: host)
        {
        case nil:
            return .rejected
        
        case (let result, let model)?:
            await self.deployment.push(snapshot: model)
            return result
        }
    }
}
