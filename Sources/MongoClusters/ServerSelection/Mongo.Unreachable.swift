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
            true
        case (.errored(let lhs), .errored(let rhs)):
            lhs == rhs
        case (_, _):
            false
        }
    }
}
extension Mongo.Unreachable
{
    /// Updates the stored error with the given error, if non-nil.
    /// If `status` is nil and the descriptor is already in an
    /// errored state, the descriptor will remain in that state, and the
    /// stored error will not be overwritten.
    @inlinable public mutating
    func clear(status:(any Error)?)
    {
        // only overwrite an existing error if we have a new one
        if  let error:any Error = status
        {
            self = .errored(error)
        }
    }
}
