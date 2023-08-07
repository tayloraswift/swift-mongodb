extension Mongo.PipelineStage
{
    @frozen public
    enum Bucket:String, Hashable, Sendable
    {
        case bucket = "$bucket"
    }
}
