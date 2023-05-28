extension Mongo.UpdateDocument
{
    @frozen public
    enum Pull:String, Hashable, Sendable
    {
        case pull = "$pull"
    }
}
