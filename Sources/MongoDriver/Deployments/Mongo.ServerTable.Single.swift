extension Mongo.ServerTable
{
    struct Single:Sendable
    {
        let capabilities:Mongo.DeploymentCapabilities
        let server:Mongo.Server<Mongo.Standalone>

        init(capabilities:Mongo.DeploymentCapabilities,
            server:Mongo.Server<Mongo.Standalone>)
        {
            self.capabilities = capabilities
            self.server = server
        }
    }
}
