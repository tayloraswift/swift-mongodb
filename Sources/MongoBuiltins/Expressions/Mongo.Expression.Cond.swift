extension Mongo.Expression
{
    @frozen public
    enum Cond:String, Hashable, Sendable
    {
        case cond = "$cond"
    }
}
