extension Mongo.Accumulator
{
    @frozen public
    enum Count:String, Hashable, Sendable
    {
        case count = "$count"
    }
}
