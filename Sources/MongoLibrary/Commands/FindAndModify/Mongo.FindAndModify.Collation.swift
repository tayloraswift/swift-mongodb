extension Mongo.FindAndModify
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }
}
