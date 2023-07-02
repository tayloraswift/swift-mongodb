extension Mongo.FilterDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case `as`
        case input
        case `cond`
        case limit
    }
}
