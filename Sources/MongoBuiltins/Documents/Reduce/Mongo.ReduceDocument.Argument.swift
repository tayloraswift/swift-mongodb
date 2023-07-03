extension Mongo.ReduceDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case input
        case initialValue
        case `in`
    }
}
