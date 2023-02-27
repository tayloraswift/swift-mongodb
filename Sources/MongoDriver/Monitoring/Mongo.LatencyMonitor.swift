import Durations
import OnlineCDF

extension Mongo
{
    struct LatencyMonitor:Sendable
    {
        private
        let connection:Connection
        
        private
        let consumer:AsyncThrowingStream<TopologyMonitor.Update, any Error>.Continuation

        init(_ consumer:AsyncThrowingStream<TopologyMonitor.Update, any Error>.Continuation,
            connection:Connection)
        {
            self.connection = connection
            self.consumer = consumer
        }
    }
}
extension Mongo.LatencyMonitor
{
    func monitor(every interval:Milliseconds,
        seed:Mongo.Latency,
        for pool:Mongo.ConnectionPool) async
    {
        do
        {
            let interval:Duration = .milliseconds(interval)
            var cdf:OnlineCDF = .init(resolution: 16, seed: seed.nanoseconds)

            while true
            {
                async
                let cooldown:Void = Task.sleep(for: interval)
                let deadline:ContinuousClock.Instant = .now.advanced(by: interval)

                let sample:Mongo.Latency = try await self.connection.sample(by: deadline)
                cdf.insert(sample.nanoseconds)

                let estimate:Nanoseconds = .nanoseconds(.init(cdf.estimate(quantile: 0.9)))
                pool.set(latency: estimate)

                try await cooldown
            }
        }
        catch
        {
            self.consumer.finish()
            await self.connection.close()
        }
    }
}
