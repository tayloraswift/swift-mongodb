extension Mongo.UpdateDocumentEncoder
{
    @frozen public
    enum Pop:String, Hashable, Sendable
    {
        case pop = "$pop"
    }
}
