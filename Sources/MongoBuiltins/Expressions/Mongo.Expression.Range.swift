extension Mongo.Expression
{
    @frozen public
    enum Range:String, Hashable, Sendable
    {
        case range = "$range"
    }
}
