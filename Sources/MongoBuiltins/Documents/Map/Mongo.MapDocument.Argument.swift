extension Mongo.MapDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case `as`
        case input
        case `in`
    }
}
