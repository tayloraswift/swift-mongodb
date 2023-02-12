extension Mongo.Payload
{
    @frozen public
    enum ID:String, Hashable, Sendable
    {
        case documents
        case updates
        case deletes
    }
}
