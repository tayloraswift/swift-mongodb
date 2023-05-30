extension Mongo.DeleteStatement
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }
}
