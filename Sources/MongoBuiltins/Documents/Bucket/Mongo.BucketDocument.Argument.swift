extension Mongo.BucketDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case boundaries
        case `default`
    }
}
