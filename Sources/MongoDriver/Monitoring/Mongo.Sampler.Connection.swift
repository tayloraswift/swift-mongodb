import Durations
import MongoExecutor
import NIOCore

extension Mongo.Sampler
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
extension Mongo.Sampler.Connection
{
    func sample(by deadline:ContinuousClock.Instant) async throws -> Duration
    {
        let hello:Mongo.Hello = .init(user: nil)
        //  Cannot use ``ContinousClock.measure(_:)``, because that API does not
        //  allow us to return values from the closure.
        let sent:ContinuousClock.Instant = .now
        let _:Mongo.Reply = try await self.run(command: hello, against: .admin,
            by: deadline)
        let received:ContinuousClock.Instant = .now
        return received - sent
    }
}
