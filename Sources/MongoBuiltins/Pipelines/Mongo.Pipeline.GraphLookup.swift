extension Mongo.Pipeline
{
    @frozen public
    enum GraphLookup:String, Hashable, Sendable
    {
        case graphLookup = "$graphLookup"
    }
}
