extension Mongo.Pipeline
{
    @frozen public
    enum ChangeStream:String, Hashable, Sendable
    {
        case changeStream = "$changeStream"
    }
}
