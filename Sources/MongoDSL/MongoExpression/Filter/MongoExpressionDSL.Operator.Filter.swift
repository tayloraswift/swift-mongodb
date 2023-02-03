extension MongoExpressionDSL.Operator
{
    @frozen public
    enum Filter:String, Hashable, Sendable
    {
        case filter = "$filter"
    }
}
