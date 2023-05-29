extension Mongo.CreateIndexStatement
{
    @frozen public
    enum PartialFilterExpression:String, Hashable, Sendable
    {
        case partialFilterExpression
    }
}
