extension Mongo.Pipeline
{
    @frozen public
    enum Limit:String, Hashable, Sendable
    {
        case limit = "$limit"
    }
}
