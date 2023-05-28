extension Mongo.UpdateDocument
{
    @frozen public
    enum Bit:String, Hashable, Sendable
    {
        case bit = "$bit"
    }
}
