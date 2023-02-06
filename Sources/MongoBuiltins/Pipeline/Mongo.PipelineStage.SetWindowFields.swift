extension Mongo.PipelineStage
{
    @frozen public
    enum SetWindowFields:String, Hashable, Sendable
    {
        case setWindowFields = "$setWindowFields"
    }
}
