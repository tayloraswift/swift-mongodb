import Durations

extension Mongo
{
    @frozen public
    struct TimeoutBehavior
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
        public
        var connection:Milliseconds
        /// A *default* upper limit for the total amount of time the driver
        /// will allow an operation to take.
        public
        var operation:Milliseconds

        @inlinable public
        init(connection:Milliseconds = .seconds(5),
            operation:Milliseconds = .seconds(5))
        {
            self.connection = connection
            self.operation = operation
        }
    }
}
