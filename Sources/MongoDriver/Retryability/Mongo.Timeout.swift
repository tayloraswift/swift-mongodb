import Durations

extension Mongo
{
    @usableFromInline internal
    struct Timeout:Sendable
    {
        public
        let `default`:Milliseconds

        @inlinable public
        init(default:Milliseconds)
        {
            self.default = `default`
        }
    }
}
extension Mongo.Timeout
{
    @inlinable internal
    func deadline(from start:ContinuousClock.Instant = .now) -> ContinuousClock.Instant
    {
        start.advanced(by: .milliseconds(self.default))
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
