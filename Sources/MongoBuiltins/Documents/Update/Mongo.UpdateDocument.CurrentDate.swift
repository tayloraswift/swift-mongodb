extension Mongo.UpdateDocument
{
    @frozen public
    enum CurrentDate:String, Hashable, Sendable
    {
        case currentDate = "$currentDate"
    }
}
