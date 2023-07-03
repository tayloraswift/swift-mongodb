extension Mongo.FilterDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case input
        case `cond`
        case limit
    }
}
extension Mongo.FilterDocument.Argument
{
    @available(*, unavailable, message: "use 'FilterDocument.let(_:with:)' instead")
    public static
    var `as`:Self { fatalError() }
}
