extension Mongo.PipelineStage
{
    @frozen public
    enum ChangeStream:String, Hashable, Sendable
    {
        case changeStream = "$changeStream"
    }
}
