extension Mongo.Expression
{
    @frozen public
    enum Switch:String, Hashable, Sendable
    {
        case `switch` = "$switch"
    }
}
