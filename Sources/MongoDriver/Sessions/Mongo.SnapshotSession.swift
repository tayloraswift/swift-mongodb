extension Mongo
{
    public final
    class SnapshotSession:Identifiable
    {
        public private(set)
        var snapshotTime:Mongo.Instant
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
        init(snapshotTime:Mongo.Instant, metadata:SessionMetadata, pool:SessionPool)
        {
            self.snapshotTime = snapshotTime
            self.transaction = metadata.transaction
            self.touched = metadata.touched
            self.id = metadata.id

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
@available(*, unavailable, message: "sessions have reference semantics")
extension Mongo.SnapshotSession:Sendable
{
}
