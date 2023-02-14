extension Mongo.Aggregate
{
    @frozen public
    enum Flag:String, Hashable, Sendable
    {
        case allowDiskUse
        case bypassDocumentValidation
    }
}
