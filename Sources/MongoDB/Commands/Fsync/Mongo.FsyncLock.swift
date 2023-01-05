import BSONDecoding

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
extension Mongo.FsyncLock:BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(count: try bson["lockCount"].decode(to: Int.self))
    }
}
