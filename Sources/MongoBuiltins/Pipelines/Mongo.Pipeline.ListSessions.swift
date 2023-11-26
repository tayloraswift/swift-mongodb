extension Mongo.Pipeline
{
    @frozen public
    enum ListSessions:String, Hashable, Sendable
    {
        case listSessions = "$listSessions"
    }
}
