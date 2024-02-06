extension Mongo.UpdateDocumentEncoder
{
    @frozen public
    enum Rename:String, Hashable, Sendable
    {
        case rename = "$rename"
    }
}
