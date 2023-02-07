extension Mongo.CollectionStatsDocument
{
    @frozen public
    enum StorageStats:String, Hashable, Sendable
    {
        case storageStats
    }
}
