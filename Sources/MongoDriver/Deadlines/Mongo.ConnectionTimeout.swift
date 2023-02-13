import Durations

extension Mongo
{
    /// An upper limit for the amount of time the driver will wait to
    /// obtain a connection to a suitable server.
    ///
    /// The following procedures are subject to this timeout, even if the
    /// overall operation timeout for the relevant operation is longer.
    ///
    /// 1.  **Session aquisition**:
    ///     Waiting for a topology to indicate it supports logical sessions.
    /// 2.  **Server selection**:
    ///     Waiting for a suitable server to become available, either by
    ///     discovering one, or waiting for one to transition from an
    ///     unsuitable state into a suitable state.
    /// 3.  **Connection checkout and establishment**: Waiting for a
    ///     connection to that server to become available, either by
    ///     establishing one, or waiting for one to be released by another
    ///     task.
    ///
    /// A long delay in performing any of the above procedures usually
    /// indicates the deployment is not in a healthy state, so it is often
    /// useful to enforce a separate time limit for this.
    @frozen public
    struct ConnectionTimeout:Sendable
    {
        public
        let milliseconds:Milliseconds

        @inlinable public
        init(milliseconds:Milliseconds)
        {
            self.milliseconds = milliseconds
        }
    }
}
extension Mongo.ConnectionTimeout:MongoTimeout
{
    public
    typealias Deadline = Mongo.ConnectionDeadline
}
extension Mongo.ConnectionTimeout
{
    /// Computes a connection deadline from the current time using this connection
    /// timeout, and clamps it to the given operation deadline, if the operation
    /// deadline is non-[`nil`]() and earlier than the computed deadline.
    public nonisolated
    func deadline(from started:ContinuousClock.Instant = .now,
        clamping operation:ContinuousClock.Instant?) -> Mongo.ConnectionDeadline
    {
        let connection:Mongo.ConnectionDeadline = self.deadline(from: .init(started))
        return operation.map { min(connection, .init($0)) } ?? connection
    }
}
