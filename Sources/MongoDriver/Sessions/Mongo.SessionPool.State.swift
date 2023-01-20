extension Mongo.SessionPool
{
    /// The current stage of a session pool’s lifecycle.
    enum State
    {
        /// The session pool is active and can create new sessions.
        case filling
        /// The session pool is inactive and cannot create new sessions.
        case draining(CheckedContinuation<Void, Never>?)
    }
}
