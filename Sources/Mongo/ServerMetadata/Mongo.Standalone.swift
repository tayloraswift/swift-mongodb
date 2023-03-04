extension Mongo
{
    public
    struct Standalone:Sendable
    {
        public
        let capabilities:ServerCapabilities

        public
        init(capabilities:ServerCapabilities)
        {
            self.capabilities = capabilities
        }
    }
}
