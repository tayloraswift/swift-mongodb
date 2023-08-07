extension Mongo.Expression
{
    @frozen public
    enum In:String, Hashable, Sendable
    {
        case `in` = "$in"
    }
}
