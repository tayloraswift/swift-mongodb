extension Mongo
{
    @frozen public
    struct Deadlines:Sendable
    {
        /// A time limit for how long the driver will wait to obtain a
        /// connection to a suitable server.
        ///
        /// The following procedures are subject to this deadline, even if the
        /// overall operation deadline for the relevant operation is later.
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
        let connection:ContinuousClock.Instant
        /// A time limit for how long the driver will wait for a reply from
        /// a selected server.
        public
        let operation:ContinuousClock.Instant

        @inlinable public
        init(connection:ContinuousClock.Instant, operation:ContinuousClock.Instant)
        {
            self.connection = connection
            self.operation = operation
        }
    }
}
