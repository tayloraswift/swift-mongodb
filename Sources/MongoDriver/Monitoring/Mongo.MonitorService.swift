extension Mongo
{
    @frozen public
    enum MonitorService:Sendable
    {
        /// The sampler.
        case sampler
        /// The listener.
        case listener
        /// The topology model.
        case topology
        /// The connection pool.
        case pool
    }
}
extension Mongo.MonitorService:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .listener: "monitor.listener"
        case .pool:     "monitor.pool"
        case .sampler:  "monitor.sampler"
        case .topology: "monitor.topology"
        }
    }
}
