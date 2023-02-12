extension Mongo.PredicateDocument
{
    @frozen public
    enum Expr:String, Hashable, Sendable
    {
        case expr = "$expr"
    }
}
