import Heartbeats
import MongoExecutor
import NIOCore

extension Mongo.LatencyMonitor
{
    struct Connection:MongoExecutor
    {
        let heartbeat:Heartbeat
        let channel:any Channel
        let timeout:Timeout

        init(heartbeat:Heartbeat, channel:any Channel, timeout:Timeout)
        {
            self.heartbeat = heartbeat
            self.channel = channel
            self.timeout = timeout
        }
    }
}
extension Mongo.LatencyMonitor.Connection
{
    func sample() async throws -> Mongo.Latency
    {
        let deadline:ContinuousClock.Instant = self.timeout.deadline()
        let hello:Mongo.Hello = .init(user: nil)
        //  Cannot use ``ContinousClock.measure(_:)``, because that API does not
        //  allow us to return values from the closure.
        let sent:ContinuousClock.Instant = .now
        let _:Mongo.Reply = try await self.run(command: hello, against: .admin,
            by: deadline)
        let received:ContinuousClock.Instant = .now
        return .init(received - sent)
    }
}
