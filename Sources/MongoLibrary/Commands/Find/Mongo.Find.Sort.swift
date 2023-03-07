extension Mongo.Find
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort
    }
}
