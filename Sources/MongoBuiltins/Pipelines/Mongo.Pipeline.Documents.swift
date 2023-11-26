extension Mongo.Pipeline
{
    @frozen public
    enum Documents:String, Hashable, Sendable
    {
        case documents = "$documents"
    }
}
