extension Mongo.Expression
{
    @frozen public
    enum Filter:String, Hashable, Sendable
    {
        case filter = "$filter"
    }
}
