import MongoIO

extension Mongo
{
    /// A command was timed-out by the driver because the its deadline has already passed.
    ///
    /// This error indicates that the command was never sent over the wire to begin with.
    @frozen public
    struct DriverTimeoutError:Error, Equatable, Sendable
    {
        @inlinable public
        init()
        {
        }
    }
}
