extension Mongo.ConnectionPool
{
    /// The current stage of a connection pool’s lifecycle.
    enum State
    {
        /// The connection pool is active and can create new connections.
        case filling(Mongo.Connector)
        /// The connection pool is inactive and cannot create new connections.
        case draining(CheckedContinuation<Void, Never>?)
    }
}
