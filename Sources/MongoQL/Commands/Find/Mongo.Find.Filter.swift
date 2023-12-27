extension Mongo.Find
{
    @frozen public
    enum Filter:String, Hashable, Sendable
    {
        case filter
    }
}
