extension MongoPipeline.BucketAuto
{
    @frozen public
    enum Granularity:String, Hashable, Sendable
    {
        case granularity
    }
}
