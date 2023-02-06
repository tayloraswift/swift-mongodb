extension Mongo.FilterDocument
{
    @frozen public
    enum For:String, Hashable, Sendable
    {
        case `for` = "as"
    }
}
