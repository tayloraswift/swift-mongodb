extension Mongo
{
    public
    struct SnapshotSession:Identifiable
    {
        public
        let connectionTimeout:Duration
        public
        let cluster:Mongo.Cluster
        @usableFromInline
        let state:State
        public
        let id:SessionIdentifier

        init(on cluster:Mongo.Cluster,
            connectionTimeout:Duration,
            snapshotTime:Mongo.Instant,
            metadata:SessionMetadata,
            id:SessionIdentifier)
        {
            self.state = .init(metadata, snapshotTime: snapshotTime)

            self.connectionTimeout = connectionTimeout
            self.cluster = cluster
            self.id = id
        }
    }
}
@available(*, unavailable, message: "sessions have reference semantics")
extension Mongo.SnapshotSession:Sendable
{
}
