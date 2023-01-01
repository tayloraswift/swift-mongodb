import MongoChannel

extension MongoTopology
{
    public
    struct Update:Sendable
    {
        public
        let parameters:DeploymentParameters
        public
        let channel:MongoChannel
        public
        let variant:Variant?

        @inlinable public
        init(parameters:DeploymentParameters, channel:MongoChannel, variant:Variant)
        {
            self.parameters = parameters
            self.channel = channel
            self.variant = variant
        }
    }
}
