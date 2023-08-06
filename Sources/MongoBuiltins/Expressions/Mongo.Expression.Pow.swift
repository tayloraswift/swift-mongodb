extension Mongo.Expression
{
    @frozen public
    enum Pow:String, Hashable, Sendable
    {
        case pow = "$pow"
    }
}
