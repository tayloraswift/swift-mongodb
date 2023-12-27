extension Mongo.FindAndModify
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort
    }
}
