import Durations
import MongoExecutor
import NIOCore

extension Mongo.Listener
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
extension Mongo.Listener.Connection
{
    func run(hello:__owned Mongo.Hello,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.Handshake
    {
        //  Cannot use ``ContinousClock.measure(_:)``, because that API does not
        //  allow us to return values from the closure.
        let sent:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await self.run(command: hello, against: .admin,
            by: deadline.instant)
        let received:ContinuousClock.Instant = .now
        return .init(response: try .init(bson: reply()),
            latency: .init(truncating: received - sent))
    }
    func run(hello:__owned Mongo.AwaitableHello) async throws -> Mongo.HelloResponse
    {
        let time:Duration = .milliseconds(hello.milliseconds)
        return try .init(bson: try await self.run(command: hello, against: .admin,
            by: .now.advanced(by: time * 1.5))())
    }
}
