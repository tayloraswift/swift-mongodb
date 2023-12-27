extension Mongo.FindAndModify
{
    @frozen public
    enum Fields:String, Hashable, Sendable
    {
        case fields
    }
}
