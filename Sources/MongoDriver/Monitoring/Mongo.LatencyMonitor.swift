import Durations
import Heartbeats
import MongoExecutor

extension Mongo
{
    struct LatencyMonitor:Sendable
    {
        private
        let connection:Connection
        private
        let consumer:AsyncStream<MonitorUpdate>.Continuation

        init(_ consumer:AsyncStream<MonitorUpdate>.Continuation,
            using connection:Connection)
        {
            self.connection = connection
            self.consumer = consumer
        }
    }
}
extension Mongo.LatencyMonitor
{
    func stop()
    {
        self.connection.heartbeat.heart.stop()
        self.connection.interrupt()
    }
    func monitor(seed:Mongo.Latency) async
    {
        var latency:Mongo.LatencyCDF = .init(seed: seed, notifying: pool)
        defer
        {
            self.consumer.finish()
        }
        for await _:Void in self.connection.heartbeat
        {
            self.consumer.yield(.latency(try await self.connection.sample())
        }
    }
}
