extension Mongo.Pipeline
{
    @frozen public
    enum Lookup:String, Hashable, Sendable
    {
        case lookup = "$lookup"
    }
}
