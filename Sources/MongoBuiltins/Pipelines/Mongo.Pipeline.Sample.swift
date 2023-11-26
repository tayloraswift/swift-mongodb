extension Mongo.Pipeline
{
    @frozen public
    enum Sample:String, Hashable, Sendable
    {
        case sample = "$sample"
    }
}
