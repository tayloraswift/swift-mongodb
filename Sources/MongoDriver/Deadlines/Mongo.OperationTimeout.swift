import Durations

extension Mongo
{
    @frozen public
    struct OperationTimeout:Sendable
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
extension Mongo.OperationTimeout:MongoTimeout
{
    public
    typealias Deadline = ContinuousClock.Instant
}
extension Mongo.OperationTimeout:ExpressibleByIntegerLiteral
{
}
