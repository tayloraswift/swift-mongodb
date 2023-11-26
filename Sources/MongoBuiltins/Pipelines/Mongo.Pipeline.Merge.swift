extension Mongo.Pipeline
{
    @frozen public
    enum Merge:String, Hashable, Sendable
    {
        case merge = "$merge"
    }
}
