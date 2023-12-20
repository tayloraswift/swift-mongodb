import BSON

extension Mongo
{
    public
    struct Replica:Sendable
    {
        public
        let capabilities:ServerCapabilities
        public
        let timings:Timings
        public
        let tags:[BSON.Key: String]

        public
        init(capabilities:ServerCapabilities,
            timings:Timings,
            tags:[BSON.Key: String])
        {
            self.capabilities = capabilities
            self.timings = timings
            self.tags = tags
        }
    }
}
