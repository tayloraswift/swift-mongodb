extension Mongo.FindAndModify
{
    @frozen public
    enum Hint:String, Hashable, Sendable
    {
        case hint
    }
}
