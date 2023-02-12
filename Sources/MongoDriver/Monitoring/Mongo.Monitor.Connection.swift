import Heartbeats
import MongoChannel

extension Mongo.Monitor
{
    struct Connection
    {
        let heartbeat:Heartbeat
        private
        let channel:MongoChannel

        private
        init(heartbeat:Heartbeat, channel:MongoChannel)
        {
            self.heartbeat = heartbeat
            self.channel = channel
        }
    }
}
extension Mongo.Monitor.Connection
{
    /// Sets up a TCP channel to the given host alongside a heartbeat that
    /// will stop if the channel is closed (for any reason).
    init(using bootstrap:__shared Mongo.ConnectionPool.Bootstrap,
        for host:__shared Mongo.Host) async throws
    {
        let heartbeat:Heartbeat = .init(interval: .milliseconds(bootstrap.heartbeatInterval))
        let channel:MongoChannel = .init(try await bootstrap.bootstrap(for: host).connect(
            host: host.name,
            port: host.port).get())
        
        channel.whenClosed
        {
            //  when the checker task is cancelled, it will also close the
            //  connection again, which will be a no-op.
            switch $0
            {
            case .success(()):
                heartbeat.heart.stop()
            case .failure(let error):
                heartbeat.heart.stop(throwing: error)
            }
        }

        self.init(heartbeat: heartbeat, channel:  channel)
    }

    func close() async
    {
        await self.channel.close()
    }
}
extension Mongo.Monitor.Connection
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
        return .init(response: try .init(bson: reply.result.get()),
            latency: received - sent)
    }
}
