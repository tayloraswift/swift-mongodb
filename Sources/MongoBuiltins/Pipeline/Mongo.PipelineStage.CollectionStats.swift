extension Mongo.PipelineStage
{
    @frozen public
    enum CollectionStats:String, Hashable, Sendable
    {
        case collectionStats = "$collStats"
    }
}
extension Mongo.PipelineStage.CollectionStats
{
    @available(*, unavailable, renamed: "collectionStats")
    public static
    var collStats:Self
    {
        .collectionStats
    }
}

