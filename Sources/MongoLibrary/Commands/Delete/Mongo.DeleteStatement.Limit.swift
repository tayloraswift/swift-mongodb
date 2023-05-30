extension Mongo.DeleteStatement
{
    @frozen public
    enum Limit:String, Hashable, Sendable
    {
        case limit
    }
}
