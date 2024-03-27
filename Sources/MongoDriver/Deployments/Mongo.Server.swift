import Durations
import MongoClusters

extension Mongo
{
    struct Server<Metadata>
    {
        let metadata:Metadata
        let pool:ConnectionPool

        init(metadata:Metadata, pool:ConnectionPool)
        {
            self.metadata = metadata
            self.pool = pool
        }
    }
}
extension Mongo.Server
{
    var host:Mongo.Host
    {
        self.pool.host
    }
}
extension Mongo.Server:Sendable where Metadata:Sendable
{
}
extension Mongo.Server<Mongo.ReplicaQuality>
{
    /// Computes the quality of a **primary** replica.
    ///
    /// The primary always has a staleness of zero, even though the standard formula would
    /// suggest it have a staleness of `heartbeatFrequency`:
    ///
    /// ```text
    /// Non-secondary servers (including Mongos servers) have zero
    /// staleness.
    /// ```
    ///
    /// Therefore, this constructor just reads the latency from the replica’s connection pool.
    static
    func primary(from self:Mongo.Server<Mongo.Replica>) -> Self
    {
        .init(metadata: .init(staleness: .zero,
                latency: self.pool.recentLatency(),
                tags: self.metadata.tags),
            pool: self.pool)
    }

    /// Computes the quality of a **secondary** replica.
    static
    func secondary(from self:Mongo.Server<Mongo.Replica>,
        heartbeatInterval:Milliseconds,
        freshest:some Mongo.ReplicaTimingBaseline) -> Self
    {
        let staleness:Milliseconds = freshest - self.metadata.timings + heartbeatInterval
        return .init(metadata: .init(
                staleness: staleness,
                latency: self.pool.recentLatency(),
                tags: self.metadata.tags),
            pool: self.pool)
    }
}
