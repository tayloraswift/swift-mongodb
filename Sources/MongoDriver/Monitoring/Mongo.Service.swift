extension Mongo
{
    enum Service:Sendable
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
