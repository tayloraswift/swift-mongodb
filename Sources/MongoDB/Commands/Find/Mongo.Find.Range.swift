extension Mongo.Find
{
    @frozen public
    enum Range:String, Hashable, Sendable
    {
        case max
        case min
    }
}
