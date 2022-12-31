import MongoConnection

extension MongoTopology
{
    @frozen public
    enum Unreachable:Sendable
    {
        case errored(any Error)
        case queued
    }
}
extension MongoTopology.Unreachable
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
