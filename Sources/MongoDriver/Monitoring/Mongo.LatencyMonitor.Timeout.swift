import Durations

extension Mongo.LatencyMonitor
{
    @frozen public
    struct Timeout:Sendable
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
extension Mongo.LatencyMonitor.Timeout:MongoTimeout
{
    public
    typealias Deadline = ContinuousClock.Instant
}
