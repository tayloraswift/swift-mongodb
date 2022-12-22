extension Mongo
{
    public
    struct SnapshotSession:Identifiable
    {
        @usableFromInline
        let state:State
        // TODO: implement time gossip
        let monitor:Mongo.TopologyMonitor
        private
        let medium:SessionMedium
        public
        let id:SessionIdentifier

        init(monitor:Mongo.TopologyMonitor,
            metadata:SessionMetadata,
            medium:SessionMedium,
            id:SessionIdentifier)
        {
            self.monitor = monitor
            self.medium = medium
            self.id = id
            
            fatalError("unimplemented")
        }
    }
}
@available(*, unavailable, message: "sessions have reference semantics")
extension Mongo.SnapshotSession:Sendable
{
}
