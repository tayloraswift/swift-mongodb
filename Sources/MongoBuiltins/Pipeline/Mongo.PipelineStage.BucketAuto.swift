extension Mongo.PipelineStage
{
    @frozen public
    enum BucketAuto:String, Hashable, Sendable
    {
        case bucketAuto = "$bucketAuto"
    }
}
