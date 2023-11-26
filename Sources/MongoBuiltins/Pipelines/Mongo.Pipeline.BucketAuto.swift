extension Mongo.Pipeline
{
    @frozen public
    enum BucketAuto:String, Hashable, Sendable
    {
        case bucketAuto = "$bucketAuto"
    }
}
