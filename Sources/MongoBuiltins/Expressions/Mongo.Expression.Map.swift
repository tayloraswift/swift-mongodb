extension Mongo.Expression
{
    @frozen public
    enum Map:String, Hashable, Sendable
    {
        case map = "$map"
    }
}
