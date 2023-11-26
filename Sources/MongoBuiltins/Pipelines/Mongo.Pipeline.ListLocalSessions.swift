extension Mongo.Pipeline
{
    @frozen public
    enum ListLocalSessions:String, Hashable, Sendable
    {
        case listLocalSessions = "$listLocalSessions"
    }
}
