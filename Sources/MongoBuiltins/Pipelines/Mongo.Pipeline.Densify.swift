extension Mongo.Pipeline
{
    @frozen public
    enum Densify:String, Hashable, Sendable
    {
        case densify = "$densify"
    }
}
