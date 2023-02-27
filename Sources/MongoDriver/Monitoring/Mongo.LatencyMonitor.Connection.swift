import Durations
import MongoExecutor
import NIOCore

extension Mongo.LatencyMonitor
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
extension Mongo.LatencyMonitor.Connection
{
    func sample(by deadline:ContinuousClock.Instant) async throws -> Mongo.Latency
    {
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
