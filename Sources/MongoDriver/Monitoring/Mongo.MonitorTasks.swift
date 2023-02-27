import Durations

extension Mongo
{
    struct MonitorTasks:Sendable
    {
        let consumer:AsyncThrowingStream<Mongo.TopologyMonitor.Update, any Error>.Continuation

        private
        let topologyMonitorConnection:TopologyMonitor.Connection,
            latencyMonitorConnection:LatencyMonitor.Connection

        private
        let handshake:Handshake
        private
        let interval:Milliseconds
        private
        let host:Host

        init(consumer:AsyncThrowingStream<Mongo.TopologyMonitor.Update, any Error>.Continuation,
            topologyMonitorConnection:TopologyMonitor.Connection,
            latencyMonitorConnection:LatencyMonitor.Connection,
            handshake:Mongo.Handshake,
            interval:Milliseconds,
            host:Host)
        {
            self.consumer = consumer
            self.topologyMonitorConnection = topologyMonitorConnection
            self.latencyMonitorConnection = latencyMonitorConnection
            self.handshake = handshake
            self.interval = interval
            self.host = host
        }
    }
}
extension Mongo.MonitorTasks
{
    var topology:Mongo.TopologyMonitor
    {
        .init(self.consumer, connection: topologyMonitorConnection)
    }
    var latency:Mongo.LatencyMonitor
    {
        .init(self.consumer, connection: latencyMonitorConnection)
    }
}
extension Mongo.MonitorTasks
{
    func pool(generation:UInt,
        settings:Mongo.ConnectionPool.Settings,
        logger:Mongo.Logger?) -> Mongo.ConnectionPool
    {
        let pool:Mongo.ConnectionPool = .init(self.consumer,
            generation: generation,
            settings: settings,
            logger: logger,
            host: self.host)
        
        self.consumer.yield(.init(
            topology: self.handshake.response.topologyUpdate,
            sessions: self.handshake.response.sessions,
            canary: .init(consumer, pool: pool)))

        pool.set(latency: .init(truncating: self.handshake.latency.duration))

        return pool
    }
}
extension Mongo.MonitorTasks
{
    func start(connectionTimeout:Mongo.ConnectionTimeout,
        connectorFactory:Mongo.ConnectorFactory,
        authenticator:__owned Mongo.Authenticator,
        pool:Mongo.ConnectionPool) async
    {
        await withTaskGroup(of: Void.self)
        {
            (tasks:inout TaskGroup<Void>) in

            tasks.addTask
            {
                await self.latency.monitor(every: self.interval,
                    seed: self.handshake.latency,
                    for: pool)
            }
            
            tasks.addTask
            {
                await self.topology.monitor(every: self.interval,
                    seed: self.handshake.response.topologyVersion)
            }

            await pool.start(connectionTimeout: connectionTimeout,
                connectorFactory: connectorFactory,
                authenticator: authenticator)
        }
    }
}
