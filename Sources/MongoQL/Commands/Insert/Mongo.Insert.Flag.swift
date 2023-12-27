extension Mongo.Insert
{
    //  Note: this has the exact same cases as ``Mongo.Update.Flag``,
    //  but it’s a distinct type because it’s for a different API.
    @frozen public
    enum Flag:String, Equatable, Hashable, Sendable
    {
        case bypassDocumentValidation
        case ordered
    }
}
