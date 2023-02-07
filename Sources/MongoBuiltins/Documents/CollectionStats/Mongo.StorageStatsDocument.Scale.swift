extension Mongo.StorageStatsDocument
{
    @frozen public
    enum Scale:String, Hashable, Sendable
    {
        case scale
    }
}
