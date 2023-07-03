extension Mongo.MapDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case input
        case `in`
    }
}
extension Mongo.MapDocument.Argument
{
    @available(*, unavailable, message: "use 'MapDocument.let(_:with:)' instead")
    public static
    var `as`:Self { fatalError() }
}
