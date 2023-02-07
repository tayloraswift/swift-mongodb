extension Mongo.MapDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case `for` = "as"
        case input
        case transform = "in"
    }
}
