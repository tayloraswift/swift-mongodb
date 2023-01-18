import TraceableErrors

extension Mongo
{
    /// A reason why a server was deemed *unreachable*.
    @frozen public
    enum Unreachable:Sendable
    {
        case errored(any Error)
        case queued
    }
}
extension Mongo.Unreachable:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.queued, .queued):
            return true
        case (.errored(let lhs), .errored(let rhs)):
            return lhs == rhs
        case (_, _):
            return false
        }
    }
}
extension Mongo.Unreachable
{
    /// Updates the stored error with the given error, if non-[`nil`]().
    /// If `status` is [`nil`]() and the descriptor is already in an
    /// errored state, the descriptor will remain in that state, and the
    /// stored error will not be overwritten.
    ///
    /// -   Returns: [`true`](), always.
    @discardableResult
    @inlinable public mutating
    func clear(status:(any Error)?) -> Bool
    {
        // only overwrite an existing error if we have a new one
        if  let error:any Error = status
        {
            self = .errored(error)
        }
        return true
    }
}
