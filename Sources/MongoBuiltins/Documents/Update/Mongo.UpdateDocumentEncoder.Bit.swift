extension Mongo.UpdateDocumentEncoder
{
    @frozen public
    enum Bit:String, Hashable, Sendable
    {
        case bit = "$bit"
    }
}
