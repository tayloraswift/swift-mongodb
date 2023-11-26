extension Mongo.Pipeline
{
    @frozen public
    enum ReplaceWith:String, Hashable, Sendable
    {
        case replaceWith = "$replaceWith"
    }
}
extension Mongo.Pipeline.ReplaceWith
{
    @available(*, unavailable, message: "Use the 'replaceWith' stage instead.")
    public static
    var replaceRoot:Self
    {
        fatalError()
    }
}
