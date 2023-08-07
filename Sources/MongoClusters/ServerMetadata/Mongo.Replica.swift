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
        let tags:[String: String]

        public
        init(capabilities:ServerCapabilities,
            timings:Timings,
            tags:[String: String])
        {
            self.capabilities = capabilities
            self.timings = timings
            self.tags = tags
        }
    }
}
