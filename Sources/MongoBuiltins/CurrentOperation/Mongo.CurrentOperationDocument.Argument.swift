extension Mongo.CurrentOperationDocument
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case allUsers
        case idleConnections
        case idleCursors
        case idleSessions
        case localOperations
    }
}
extension Mongo.CurrentOperationDocument.Argument
{
    @available(*, unavailable, renamed: "localOperations")
    public static
    var localOps:Self
    {
        .localOperations
    }
}
