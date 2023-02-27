extension Mongo.Monitor
{
    struct State:Sendable
    {
        let connectionPoolSettings:Mongo.ConnectionPool.Settings
        let connectorFactory:Mongo.ConnectorFactory
        let authenticator:Mongo.Authenticator

        var topology:Mongo.Topology<Mongo.TopologyMonitor.Canary>

        init(connectionPoolSettings:Mongo.ConnectionPool.Settings,
            connectorFactory:Mongo.ConnectorFactory,
            authenticator:Mongo.Authenticator,
            topology:Mongo.Topology<Mongo.TopologyMonitor.Canary>)
        {
            self.connectionPoolSettings = connectionPoolSettings
            self.connectorFactory = connectorFactory
            self.authenticator = authenticator
            
            self.topology = topology
        }
    }
}
