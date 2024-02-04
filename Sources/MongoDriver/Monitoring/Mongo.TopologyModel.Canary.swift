extension Mongo.TopologyModel
{
    /// A type that can notify a monitor delegate when it is
    /// removed from a topology model.
    final
    class Canary:Sendable
    {
        let pool:Mongo.ConnectionPool

        init(pool:Mongo.ConnectionPool)
        {
            self.pool = pool
        }

        deinit
        {
            self.pool.monitor.resume(from: .topology)
            self.pool.log(event: Event.removed)
        }
    }
}
