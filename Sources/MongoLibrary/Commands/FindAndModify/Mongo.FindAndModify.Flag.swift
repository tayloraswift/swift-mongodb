extension Mongo.FindAndModify
{
    @frozen public
    enum Flag:String, Hashable, Sendable
    {
        case bypassDocumentValidation
    }
}
