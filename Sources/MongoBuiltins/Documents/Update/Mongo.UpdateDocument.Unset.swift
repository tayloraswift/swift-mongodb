extension Mongo.UpdateDocument
{
    @frozen public
    enum Unset:String, Hashable, Sendable
    {
        case unset = "$unset"
    }
}
