import OnlineCDF
import Durations

extension Mongo
{
    struct LatencyCDF:Sendable
    {
        private
        var cdf:OnlineCDF

        private
        init(cdf:OnlineCDF)
        {
            self.cdf = cdf
        }
    }
}
extension Mongo.LatencyCDF
{
    init(seed latency:Mongo.Latency, notifying pool:__shared Mongo.ConnectionPool)
    {
        self.init(cdf: .init(resolution: 16, seed: latency.nanoseconds))
        self.notify(pool: pool)
        
    }

    mutating
    func insert(_ latency:Mongo.Latency, notifying pool:Mongo.ConnectionPool)
    {
        self.cdf.insert(latency.nanoseconds)
        self.notify(pool: pool)
    }

    private
    func notify(pool:__shared Mongo.ConnectionPool)
    {
        pool.set(latency: .nanoseconds(.init(self.cdf.estimate(quantile: 0.9))))
    }
}
