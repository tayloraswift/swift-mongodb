extension Mongo.Pipeline
{
    @frozen public
    enum CurrentOperation:String, Hashable, Sendable
    {
        case currentOperation = "$currentOp"
    }
}
extension Mongo.Pipeline.CurrentOperation
{
    @available(*, unavailable, renamed: "currentOperation")
    public static
    var currentOp:Self
    {
        .currentOperation
    }
}
