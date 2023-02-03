extension MongoExpressionDSL.Operator
{
    @frozen public
    enum Pow:String, Hashable, Sendable
    {
        case pow = "$pow"
    }
}
