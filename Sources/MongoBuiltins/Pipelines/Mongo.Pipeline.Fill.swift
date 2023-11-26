extension Mongo.Pipeline
{
    @frozen public
    enum Fill:String, Hashable, Sendable
    {
        case fill = "$fill"
    }
}
