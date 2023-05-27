extension Mongo
{
    public final
    class SnapshotSession:Identifiable
    {
        public private(set)
        var snapshotTime:Timestamp
        public private(set)
        var transaction:TransactionState
        private
        var touched:ContinuousClock.Instant

        public
        let id:SessionIdentifier

        /// The server cluster associated with this session’s ``pool``.
        /// This is stored inline to speed up access.
        @usableFromInline
        let deployment:Deployment
        private
        let pool:SessionPool

        private
        init(snapshotTime:Timestamp, allocation:SessionPool.Allocation, pool:SessionPool)
        {
            self.snapshotTime = snapshotTime
            self.transaction = allocation.transaction
            self.touched = allocation.touched
            self.id = allocation.id

            self.deployment = pool.deployment
            self.pool = pool
        }
        deinit
        {
            self.pool.destroy(.init(
                    transaction: self.transaction,
                    touched: self.touched,
                    id: self.id),
                reuse: true)
        }
    }
}

#if swift(>=5.9)
@available(*, unavailable, message: "sessions have reference semantics")
extension Mongo.SnapshotSession:Sendable
{
}
#endif
