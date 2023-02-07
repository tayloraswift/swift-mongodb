extension Mongo.CollectionStatsDocument
{
    @frozen public
    enum Keyword:String, Hashable, Sendable
    {
        case count
        case queryExecutionStats
    }
}
extension Mongo.CollectionStatsDocument.Keyword
{
    @available(*, unavailable, renamed: "queryExecutionStats")
    public static
    var queryExecStats:Self
    {
        .queryExecutionStats
    }
}
