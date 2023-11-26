extension Mongo.Pipeline
{
    @frozen public
    enum CollectionStats:String, Hashable, Sendable
    {
        case collectionStats = "$collStats"
    }
}
extension Mongo.Pipeline.CollectionStats
{
    @available(*, unavailable, renamed: "collectionStats")
    public static
    var collStats:Self
    {
        .collectionStats
    }
}

