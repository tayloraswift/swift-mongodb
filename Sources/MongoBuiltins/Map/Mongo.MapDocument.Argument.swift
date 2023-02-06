extension Mongo.MapDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case input
        case transform = "in"
    }
}
