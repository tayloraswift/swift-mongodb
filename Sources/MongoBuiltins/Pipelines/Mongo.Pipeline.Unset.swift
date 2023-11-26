extension Mongo.Pipeline
{
    @frozen public
    enum Unset:String, Hashable, Sendable
    {
        case unset = "$unset"
    }
}
