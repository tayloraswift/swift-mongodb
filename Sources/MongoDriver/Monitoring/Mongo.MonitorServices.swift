import Durations

extension Mongo
{
    struct MonitorServices:Sendable
    {
        private
        let listenerConnection:Listener.Connection,
            samplerConnection:Sampler.Connection

        private
        let handshake:Handshake

        private
        let interval:Milliseconds

        init(listenerConnection:Listener.Connection,
            samplerConnection:Sampler.Connection,
            handshake:Mongo.Handshake,
            interval:Milliseconds)
        {
            self.listenerConnection = listenerConnection
            self.samplerConnection = samplerConnection
            self.handshake = handshake
            self.interval = interval
        }
    }
}
extension Mongo.MonitorServices
{
    var initialTopologyUpdate:Mongo.TopologyUpdate
    {
        self.handshake.response.topologyUpdate
    }
    var initialLatency:Nanoseconds
    {
        self.handshake.latency
    }
}
extension Mongo.MonitorServices
{
    var listener:Mongo.Listener
    {
        .init(connection: self.listenerConnection,
            interval: self.interval,
            seed: self.handshake.response.topologyVersion)
    }
    var sampler:Mongo.Sampler
    {
        .init(connection: self.samplerConnection,
            interval: self.interval,
            seed: self.handshake.latency)
    }
}
