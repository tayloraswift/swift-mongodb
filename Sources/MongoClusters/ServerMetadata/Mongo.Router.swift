extension Mongo
{
    public
    struct Router:Sendable
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
