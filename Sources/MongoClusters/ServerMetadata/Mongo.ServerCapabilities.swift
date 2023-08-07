import Durations

extension Mongo
{
    @frozen public
    struct ServerCapabilities:Equatable, Sendable
    {
        /// The logical session time-to-live (TTL). Prefer accessing the
        /// typed ``logicalSessionTimeout`` instead.
        public
        let logicalSessionTimeoutMinutes:UInt32

        /// The maximum number of write operations permitted in a write batch.
        public
        let maxWriteBatchCount:Int

        /// The maximum permitted size of a BSON object in bytes for this
        /// [mongod](https://www.mongodb.com/docs/manual/reference/program/mongod/#mongodb-binary-bin.mongod)
        /// process.
        public
        let maxDocumentSize:Int

        /// The maximum permitted size of a BSON wire protocol message.
        public
        let maxMessageSize:Int

        @inlinable public
        init(logicalSessionTimeoutMinutes:UInt32,
            maxWriteBatchCount:Int,
            maxDocumentSize:Int,
            maxMessageSize:Int)
        {
            self.logicalSessionTimeoutMinutes = logicalSessionTimeoutMinutes
            self.maxWriteBatchCount = maxWriteBatchCount
            self.maxDocumentSize = maxDocumentSize
            self.maxMessageSize = maxMessageSize
        }
    }
}
extension Mongo.ServerCapabilities
{
    // The logical session time-to-live (TTL).
    @inlinable public
    var logicalSessionTimeout:Minutes
    {
        .init(rawValue: .init(self.logicalSessionTimeoutMinutes))
    }
}
