extension Mongo.PipelineStage
{
    @frozen public
    enum Redact:String, Hashable, Sendable
    {
        case redact = "$redact"
    }
}
