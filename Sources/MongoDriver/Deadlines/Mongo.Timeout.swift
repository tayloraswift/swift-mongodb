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
    @inlinable public
    func deadline(from start:ContinuousClock.Instant = .now) -> ContinuousClock.Instant
    {
        start.advanced(by: .milliseconds(self.default))
    }

    @inlinable public
    func deadlines(from started:ContinuousClock.Instant = .now,
        clamping deadline:ContinuousClock.Instant?) -> Mongo.Deadlines
    {
        let connection:ContinuousClock.Instant = self.deadline(from: started)
        return .init(connection: connection,
            operation: deadline.map { min(connection, $0) } ?? connection)
    }
}
