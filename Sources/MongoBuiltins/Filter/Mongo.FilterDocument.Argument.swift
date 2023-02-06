extension Mongo.FilterDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case `for` = "as"
        case input
        case `where` = "cond"
        case limit
    }
}
