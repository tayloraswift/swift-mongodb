import Durations

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

            var metric:Double = .init(seed.rawValue)
            let alpha:Double = 0.2

            while true
            {
                async
                let cooldown:Void = Task.sleep(for: interval)
                let deadline:ContinuousClock.Instant = .now.advanced(by: interval)

                let sampleLatency:Duration = try await self.connection.sample(by: deadline)
                let sample:Double =
                    1e-9 * Double.init(sampleLatency.components.attoseconds) +
                    1e+9 * Double.init(sampleLatency.components.seconds)

                metric = alpha * sample + (1 - alpha) * metric

                let rounded:Nanoseconds = .nanoseconds(Int64.init(metric))

                pool.updateLatency(with: rounded)
                pool.log(event: Event.sampled(sampleLatency, metric: rounded))

                try await cooldown
            }
        }
        catch let error
        {
            pool.monitor.resume(from: .sampler)
            pool.log(event: Event.errored(error))
            await self.connection.close()
        }
    }
}
