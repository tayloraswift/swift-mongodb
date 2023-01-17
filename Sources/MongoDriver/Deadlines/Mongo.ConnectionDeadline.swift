import Durations

extension Mongo
{
    @frozen public
    struct ConnectionDeadline:Sendable
    {
        public
        let instant:ContinuousClock.Instant

        @inlinable public
        init(_ instant:ContinuousClock.Instant)
        {
            self.instant = instant
        }
    }
}
extension Mongo.ConnectionDeadline
{
    @inlinable public static
    var now:Self
    {
        .init(.now)
    }
}
extension Mongo.ConnectionDeadline:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.instant < rhs.instant
    }
}
extension Mongo.ConnectionDeadline:InstantProtocol
{
    @inlinable public
    func advanced(by duration:ContinuousClock.Duration) -> Self
    {
        .init(self.instant.advanced(by: duration))
    }
    @inlinable public
    func duration(to other:Self) -> ContinuousClock.Duration
    {
        self.instant.duration(to: other.instant)
    }
}
