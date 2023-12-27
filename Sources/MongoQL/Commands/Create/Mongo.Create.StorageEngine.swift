extension Mongo.Create
{
    @frozen public
    enum StorageEngine:String, Hashable, Sendable
    {
        case storageEngine
        case indexOptionDefaults
    }
}
