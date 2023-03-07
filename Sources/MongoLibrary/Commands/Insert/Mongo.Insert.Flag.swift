extension Mongo.Insert
{
    @frozen public
    enum Flag:String, Hashable, Sendable
    {
        case bypassDocumentValidation
        case ordered
    }
}
