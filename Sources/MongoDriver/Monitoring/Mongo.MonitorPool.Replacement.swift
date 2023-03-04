extension Mongo.MonitorPool
{
    enum Replacement
    {
        /// The monitor will replace the relevant connection pool.
        case replace
        /// The monitor will not replace the relevant connection pool.
        case none
    }
}
