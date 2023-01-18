extension Mongo
{
    public
    enum CursorLifecycle
    {
        /// The timeout used for ``GetMore`` operations on the relevant cursor.
        case iterable(Mongo.OperationTimeout?)
        case expires(ContinuousClock.Instant)
    }
}
extension Mongo.CursorLifecycle
{
    @usableFromInline
    var _timeout:Mongo.OperationTimeout?
    {
        switch self
        {
        case .iterable(let timeout):    return timeout
        case .expires:                  return nil
        }
    }
}
