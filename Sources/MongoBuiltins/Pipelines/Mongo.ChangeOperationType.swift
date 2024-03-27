import BSON

extension Mongo
{
    @frozen @usableFromInline
    enum ChangeOperationType:String, BSONDecodable, Equatable, Sendable
    {
        case create
        case createIndexes
        case delete
        case drop
        case dropDatabase
        case dropIndexes
        case insert
        case invalidate
        case modify
        case refineCollectionShardKey
        case rename
        case replace
        case reshardCollection
        case shardCollection
        case update
    }
}
