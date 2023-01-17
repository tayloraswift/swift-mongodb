extension Mongo
{
    public
    enum CursorLifespan
    {
        /// The timeout used for ``GetMore`` operations on the relevant cursor.
        case iterable(Mongo.OperationTimeout?)
        case expires(ContinuousClock.Instant)
    }
}
extension Mongo.CursorLifespan
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
    public
    func deadline(default:Mongo.OperationTimeout) -> ContinuousClock.Instant
    {
        switch self
        {
        case .iterable(let timeout):
            return (timeout ?? `default`).deadline()
        case .expires(let deadline):
            return deadline
        }
    }
}
