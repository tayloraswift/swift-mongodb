import Durations

extension Mongo
{
    @frozen public
    struct ConnectionTimeout:Sendable
    {
        public
        let milliseconds:Milliseconds

        @inlinable public
        init(milliseconds:Milliseconds)
        {
            self.milliseconds = milliseconds
        }
    }
}
extension Mongo.ConnectionTimeout:MongoTimeout
{
    public
    typealias Deadline = Mongo.ConnectionDeadline
}
extension Mongo.ConnectionTimeout
{
    /// Computes a connection deadline from the current time using this connection
    /// timeout, and clamps it to the given operation deadline, if the operation
    /// deadline is non-[`nil`]() and earlier than the computed deadline.
    public nonisolated
    func deadline(from started:ContinuousClock.Instant = .now,
        clamping operation:ContinuousClock.Instant?) -> Mongo.ConnectionDeadline
    {
        let connection:Mongo.ConnectionDeadline = self.deadline(from: .init(started))
        return operation.map { min(connection, .init($0)) } ?? connection
    }
}
