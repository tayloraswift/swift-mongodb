extension Mongo.PredicateDocument
{
    @frozen public
    enum Comment:String, Hashable, Sendable
    {
        case comment = "$comment"
    }
}
