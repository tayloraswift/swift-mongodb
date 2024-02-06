extension Mongo.UpdateDocumentEncoder
{
    @frozen public
    enum Assignment:String, Hashable, Sendable
    {
        case set = "$set"
        case setOnInsert = "$setOnInsert"
    }
}
