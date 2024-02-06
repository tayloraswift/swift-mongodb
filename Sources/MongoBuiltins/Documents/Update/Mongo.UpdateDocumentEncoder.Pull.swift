extension Mongo.UpdateDocumentEncoder
{
    @frozen public
    enum Pull:String, Hashable, Sendable
    {
        case pull = "$pull"
    }
}
