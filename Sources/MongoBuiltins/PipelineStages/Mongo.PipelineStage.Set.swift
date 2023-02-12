extension Mongo.PipelineStage
{
    @frozen public
    enum Set:String, Hashable, Sendable
    {
        case set = "$set"
    }
}
extension Mongo.PipelineStage.Set
{
    @available(*, unavailable, renamed: "set")
    public static
    var addFields:Self
    {
        .set
    }
}
