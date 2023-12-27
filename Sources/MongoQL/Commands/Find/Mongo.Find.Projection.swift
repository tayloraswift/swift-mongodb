extension Mongo.Find
{
    @frozen public
    enum Projection:String, Hashable, Sendable
    {
        case projection
    }
}
