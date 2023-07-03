extension MongoExpression
{
    @frozen public
    enum Pow:String, Hashable, Sendable
    {
        case pow = "$pow"
    }
}
