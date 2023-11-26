extension Mongo.Pipeline
{
    @frozen public
    enum Set:String, Hashable, Sendable
    {
        case set = "$set"
    }
}
extension Mongo.Pipeline.Set
{
    @available(*, unavailable, renamed: "set")
    public static
    var addFields:Self
    {
        .set
    }
}
