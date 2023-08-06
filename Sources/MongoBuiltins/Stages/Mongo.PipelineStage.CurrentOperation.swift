extension Mongo.PipelineStage
{
    @frozen public
    enum CurrentOperation:String, Hashable, Sendable
    {
        case currentOperation = "$currentOp"
    }
}
extension Mongo.PipelineStage.CurrentOperation
{
    @available(*, unavailable, renamed: "currentOperation")
    public static
    var currentOp:Self
    {
        .currentOperation
    }
}
