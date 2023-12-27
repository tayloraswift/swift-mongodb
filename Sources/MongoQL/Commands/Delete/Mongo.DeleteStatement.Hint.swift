extension Mongo.DeleteStatement
{
    @frozen public
    enum Hint:String, Hashable, Sendable
    {
        case hint
    }
}
