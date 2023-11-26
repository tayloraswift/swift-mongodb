extension Mongo.Pipeline
{
    @frozen public
    enum Out:String, Hashable, Sendable
    {
        case out = "$out"
    }
}
