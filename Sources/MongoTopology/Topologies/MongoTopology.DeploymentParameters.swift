import Durations

extension MongoTopology
{
    public
    struct DeploymentParameters:Sendable
    {
        public
        var logicalSessionTimeout:Minutes
        public
        var maxWriteBatchCount:Int
        public
        var maxDocumentSize:Int
        public
        var maxMessageSize:Int

        @inlinable public
        init(logicalSessionTimeout:Minutes,
            maxWriteBatchCount:Int,
            maxDocumentSize:Int,
            maxMessageSize:Int)
        {
            self.logicalSessionTimeout = logicalSessionTimeout
            self.maxWriteBatchCount = maxWriteBatchCount
            self.maxDocumentSize = maxDocumentSize
            self.maxMessageSize = maxMessageSize
        }
    }
}
