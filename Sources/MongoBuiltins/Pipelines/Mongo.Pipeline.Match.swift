extension Mongo.Pipeline
{
    @frozen public
    enum Match:String, Hashable, Sendable
    {
        case match = "$match"
    }
}
