import Durations
import OnlineCDF

extension Mongo
{
    struct Sampler:Sendable
    {
        private
        let connection:Connection

        private
        let interval:Milliseconds,
            seed:Nanoseconds

        init(connection:Connection,
            interval:Milliseconds,
            seed:Nanoseconds)
        {
            self.connection = connection
            self.interval = interval
            self.seed = seed
        }
    }
}
extension Mongo.Sampler
{
    func start(alongside pool:Mongo.ConnectionPool) async
    {
        do
        {
            let interval:Duration = .milliseconds(self.interval)
            var cdf:OnlineCDF = .init(resolution: 16, seed: .init(self.seed.rawValue))

            while true
            {
                async
                let cooldown:Void = Task.sleep(for: interval)
                let deadline:ContinuousClock.Instant = .now.advanced(by: interval)

                let sample:Duration = try await self.connection.sample(by: deadline)

                let nanoseconds:Double =
                    1e-9 * Double.init(sample.components.attoseconds) +
                    1e+9 * Double.init(sample.components.seconds)

                cdf.insert(nanoseconds)

                let metric:Nanoseconds = .nanoseconds(.init(cdf.estimate(quantile: 0.9)))

                pool.latency.store(metric, ordering: .relaxed)
                pool.log(samplerEvent: .sampled(sample, metric: metric))

                try await cooldown
            }
        }
        catch let error
        {
            pool.monitor.resume(from: .sampler)
            pool.log(samplerEvent: .errored(error))
            await self.connection.close()
        }
    }
}
