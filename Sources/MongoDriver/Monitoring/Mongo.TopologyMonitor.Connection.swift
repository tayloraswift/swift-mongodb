import Durations
import MongoExecutor
import NIOCore

extension Mongo.TopologyMonitor
{
    struct Connection:MongoExecutor
    {
        let channel:any Channel

        init(channel:any Channel)
        {
            self.channel = channel
        }
    }
}
extension Mongo.TopologyMonitor.Connection
{
    func run(hello command:__owned Mongo.Hello,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.HelloResult
    {
        //  Cannot use ``ContinousClock.measure(_:)``, because that API does not
        //  allow us to return values from the closure.
        let sent:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await self.run(command: command, against: .admin,
            by: deadline.instant)
        let received:ContinuousClock.Instant = .now
        return .init(response: try .init(bson: reply()),
            latency: .init(received - sent))
    }
    func listen(granularity:Milliseconds) async throws -> Mongo.HelloResponse
    {
        let hello:Mongo.Hello = .init(await: granularity, user: nil)
        return try .init(bson: try await self.run(command: hello, against: .admin,
            by: .now.advanced(by: .milliseconds(granularity * 3 / 2)))())
    }
}
