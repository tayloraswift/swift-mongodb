import Durations

extension Mongo
{
    @frozen @usableFromInline
    struct NetworkTimeout:Sendable
    {
        @usableFromInline
        let milliseconds:Milliseconds

        @inlinable
        init(milliseconds:Milliseconds)
        {
            self.milliseconds = milliseconds
        }
    }
}
extension Mongo.NetworkTimeout
{
    @inlinable internal
    func deadline(from start:ContinuousClock.Instant = .now) -> ContinuousClock.Instant
    {
        start.advanced(by: .milliseconds(self.milliseconds))
    }

    @inlinable internal
    func deadlines(from started:ContinuousClock.Instant = .now,
        clamping deadline:ContinuousClock.Instant?) -> Mongo.Deadlines
    {
        let connection:ContinuousClock.Instant = self.deadline(from: started)
        if  let deadline:ContinuousClock.Instant
        {
            //  It will never make sense to have a connection timeout that is longer than
            //  the operation timeout.
            return .init(connection: min(connection, deadline), operation: deadline)
        }
        else
        {
            return .init(connection: connection, operation: connection)
        }
    }
}
