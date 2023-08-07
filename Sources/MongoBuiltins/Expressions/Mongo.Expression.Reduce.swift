extension Mongo.Expression
{
    @frozen public
    enum Reduce:String, Hashable, Sendable
    {
        case reduce = "$reduce"
    }
}
