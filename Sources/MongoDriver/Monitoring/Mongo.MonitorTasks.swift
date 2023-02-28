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
        .init(self.consumer, connection: topologyMonitorConnection,
            interval: self.interval,
            seed: self.handshake.response.topologyVersion)
    }
    var latency:Mongo.LatencyMonitor
    {
        .init(self.consumer, connection: latencyMonitorConnection,
            interval: self.interval,
            seed: self.handshake.latency)
    }
}
extension Mongo.MonitorTasks
{
    func pool(connectionTimeout:Mongo.ConnectionTimeout,
        connectorFactory:Mongo.ConnectorFactory,
        authenticator:__owned Mongo.Authenticator,
        generation:UInt,
        settings:Mongo.ConnectionPool.Settings,
        logger:Mongo.Logger?) -> Mongo.ConnectionPool
    {
        let pool:Mongo.ConnectionPool = .init(self.consumer,
            connectionTimeout: connectionTimeout,
            connectorFactory: connectorFactory,
            authenticator: authenticator,
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
