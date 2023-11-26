extension Mongo.Pipeline
{
    @frozen public
    enum Count:String, Hashable, Sendable
    {
        case count = "$count"
    }
}
