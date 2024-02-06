extension Mongo.UpdateDocumentEncoder
{
    @frozen public
    enum CurrentDate:String, Hashable, Sendable
    {
        case currentDate = "$currentDate"
    }
}
