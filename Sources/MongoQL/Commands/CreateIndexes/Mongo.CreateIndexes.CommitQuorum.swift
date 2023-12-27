extension Mongo.CreateIndexes
{
    @frozen public
    enum CommitQuorum:String, Hashable, Sendable
    {
        case commitQuorum
    }
}
