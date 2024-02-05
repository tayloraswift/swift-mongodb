import BSON

extension Mongo
{
    /// Information about a MongoDB ``Fsync`` lock.
    @frozen public
    struct FsyncLock:Hashable, Equatable, Sendable
    {
        /// The current retain count of the relevant lock.
        public
        let count:Int

        @inlinable public
        init(count:Int)
        {
            self.count = count
        }
    }
}
extension Mongo.FsyncLock:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key>) throws
    {
        self.init(count: try bson["lockCount"].decode(to: Int.self))
    }
}
