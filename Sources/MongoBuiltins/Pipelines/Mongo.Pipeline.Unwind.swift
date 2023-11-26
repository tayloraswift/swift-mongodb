extension Mongo.Pipeline
{
    @frozen public
    enum Unwind:String, Hashable, Sendable
    {
        case unwind = "$unwind"
    }
}
