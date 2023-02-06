extension Mongo.BucketAutoDocument
{
    @frozen public
    enum Granularity:String, Hashable, Sendable
    {
        case granularity
    }
}
