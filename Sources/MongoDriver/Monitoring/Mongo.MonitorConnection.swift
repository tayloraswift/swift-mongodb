import Heartbeats
import MongoChannel

extension Mongo
{
    struct MonitorConnection
    {
        let heartbeat:Heartbeat
        private
        let channel:MongoChannel

        init(heartbeat:Heartbeat, channel:MongoChannel)
        {
            self.heartbeat = heartbeat
            self.channel = channel
        }
    }
}
extension Mongo.MonitorConnection
{
    func close() async
    {
        await self.channel.close()
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
        let reply:Mongo.Reply = try await self.channel.run(command: command, against: .admin,
            by: deadline.instant)
        let received:ContinuousClock.Instant = .now
        return .init(response: try .init(bson: reply()),
            latency: received - sent)
    }
}
