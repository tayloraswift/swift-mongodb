import Durations

extension MongoTopology.Eligibility
{
    struct Staleness
    {
        let heartbeatFrequency:Milliseconds
        let maxStaleness:Milliseconds
        let reference:MongoTopology.Replicas.Freshest

        init(heartbeatFrequency:Milliseconds, maxStaleness:Milliseconds,
            reference:MongoTopology.Replicas.Freshest)
        {
            self.heartbeatFrequency = heartbeatFrequency
            self.maxStaleness = maxStaleness
            self.reference = reference
            // normalize empty list to `nil`, to simplify filtering algorithm
            // self.tagSets = tagSets.flatMap { $0.isEmpty ? nil : $0 }
        }
    }
}
extension MongoTopology.Eligibility.Staleness
{
    init?(replicas:__shared MongoTopology.Replicas,
        heartbeatFrequency:Milliseconds,
        maxStaleness:Seconds)
    {
        guard maxStaleness > 0
        else
        {
            return nil
        }
        if let reference:MongoTopology.Replicas.Freshest = replicas.freshest
        {
            self.init(heartbeatFrequency: heartbeatFrequency,
                maxStaleness: maxStaleness.milliseconds,
                reference: reference)
        }
        else
        {
            return nil
        }
    }
}
extension MongoTopology.Eligibility.Staleness
{
    func filter(candidates:inout [MongoTopology.Server<MongoTopology.Replica>])
        -> [MongoTopology.Rejection<MongoTopology.Unsuitable>]
    {
        var stale:[MongoTopology.Rejection<MongoTopology.Unsuitable>] = []
        var fresh:[MongoTopology.Server<MongoTopology.Replica>] = []
        defer
        {
            candidates = fresh
        }
        for candidate:MongoTopology.Server<MongoTopology.Replica> in candidates
        {
            let staleness:Milliseconds = candidate.connection.metadata.timings.lag(
                behind: self.reference) + self.heartbeatFrequency
            if self.maxStaleness < staleness
            {
                stale.append(.init(reason: .stale(staleness), host: candidate.host))
            }
            else
            {
                fresh.append(candidate)
            }
        }
        return stale
    }
}
