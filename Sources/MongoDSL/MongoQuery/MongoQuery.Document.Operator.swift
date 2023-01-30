extension MongoQuery.Document
{
    @frozen public
    enum Operator:String, Hashable, Sendable
    {
        case comment = "$comment"
    }
}
