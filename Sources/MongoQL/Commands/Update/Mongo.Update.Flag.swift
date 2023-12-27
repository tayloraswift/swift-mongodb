extension Mongo.Update
{
    //  Note: this has the exact same cases as ``Mongo.Insert.Flag``,
    //  but it’s a distinct type because it’s for a different API.
    @frozen public
    enum Flag:String, Equatable, Hashable, Sendable
    {
        case bypassDocumentValidation
        case ordered
    }
}
