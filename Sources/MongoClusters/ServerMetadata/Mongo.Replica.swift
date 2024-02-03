import BSON

extension Mongo
{
    public
    struct Replica:Sendable
    {
        public
        let capabilities:ServerCapabilities
        public
        let timings:ReplicaTimings
        public
        let tags:[BSON.Key: String]

        public
        init(capabilities:ServerCapabilities,
            timings:ReplicaTimings,
            tags:[BSON.Key: String])
        {
            self.capabilities = capabilities
            self.timings = timings
            self.tags = tags
        }
    }
}
