extension Mongo.PipelineStage
{
    @frozen public
    enum ListSessions:String, Hashable, Sendable
    {
        case listSessions = "$listSessions"
    }
}
