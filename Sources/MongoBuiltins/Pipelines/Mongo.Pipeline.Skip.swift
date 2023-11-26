extension Mongo.Pipeline
{
    @frozen public
    enum Skip:String, Hashable, Sendable
    {
        case skip = "$skip"
    }
}
