extension MongoExpressionDSL.Operator
{
    @frozen public
    enum Range:String, Hashable, Sendable
    {
        case range = "$range"
    }
}
