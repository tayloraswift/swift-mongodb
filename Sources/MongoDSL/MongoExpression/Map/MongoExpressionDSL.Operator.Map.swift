extension MongoExpressionDSL.Operator
{
    @frozen public
    enum Map:String, Hashable, Sendable
    {
        case map = "$map"
    }
}
