extension Mongo.Expression
{
    @frozen public
    enum Slice:String, Hashable, Sendable
    {
        case slice = "$slice"
    }
}
