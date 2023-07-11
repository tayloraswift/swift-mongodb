extension MongoExpression
{
    @frozen public
    enum Cond:String, Hashable, Sendable
    {
        case cond = "$cond"
    }
}
