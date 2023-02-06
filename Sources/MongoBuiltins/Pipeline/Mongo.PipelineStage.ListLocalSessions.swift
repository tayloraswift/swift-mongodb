extension Mongo.PipelineStage
{
    @frozen public
    enum ListLocalSessions:String, Hashable, Sendable
    {
        case listLocalSessions = "$listLocalSessions"
    }
}
