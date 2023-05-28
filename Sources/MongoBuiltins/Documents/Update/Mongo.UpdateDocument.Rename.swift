extension Mongo.UpdateDocument
{
    @frozen public
    enum Rename:String, Hashable, Sendable
    {
        case rename = "$rename"
    }
}
