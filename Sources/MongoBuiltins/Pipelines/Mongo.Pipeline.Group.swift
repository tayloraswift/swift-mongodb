extension Mongo.Pipeline
{
    @frozen public
    enum Group:String, Hashable, Sendable
    {
        case group = "$group"
    }
}
