import Heartbeats
import MongoExecutor
import NIOCore

extension Mongo
{
    struct MonitorConnection:MongoExecutor
    {
        let heartbeat:Heartbeat
        let channel:any Channel

        init(heartbeat:Heartbeat, channel:any Channel)
        {
            self.heartbeat = heartbeat
            self.channel = channel
        }
    }
}
extension Mongo.MonitorConnection
{
    /// Runs a ``Mongo/Hello`` command, and decodes a subset of its response
    /// suitable for monitoring purposes.
    func run(hello command:__owned Mongo.Hello,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.Monitor.HelloResult
    {
        //  Cannot use ``ContinousClock.measure(_:)``, because that API does not
        //  allow us to return values from the closure.
        let sent:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await self.run(command: command, against: .admin,
            by: deadline.instant)
        let received:ContinuousClock.Instant = .now
        return .init(response: try .init(bson: reply()),
            latency: received - sent)
    }
}
