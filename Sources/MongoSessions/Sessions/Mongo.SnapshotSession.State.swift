extension Mongo.SnapshotSession
{
    @usableFromInline final
    class State
    {
        @usableFromInline
        var snapshotTime:Mongo.Instant
        @usableFromInline
        var metadata:Mongo.SessionMetadata

        init(_ metadata:Mongo.SessionMetadata, snapshotTime:Mongo.Instant)
        {
            self.snapshotTime = snapshotTime
            self.metadata = metadata
        }
    }
}
