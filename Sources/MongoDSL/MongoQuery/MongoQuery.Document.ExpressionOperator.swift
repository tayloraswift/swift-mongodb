extension MongoQuery.Document
{
    @frozen public
    enum ExpressionOperator:String, Hashable, Sendable
    {
        case expr = "$expr"
    }
}
