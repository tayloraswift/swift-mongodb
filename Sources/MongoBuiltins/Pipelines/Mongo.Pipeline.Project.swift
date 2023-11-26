extension Mongo.Pipeline
{
    @frozen public
    enum Project:String, Hashable, Sendable
    {
        case project = "$project"
    }
}
