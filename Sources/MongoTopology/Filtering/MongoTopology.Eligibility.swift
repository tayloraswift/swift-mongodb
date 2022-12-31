import Durations
import MongoChannel

extension MongoTopology
{
    struct Eligibility
    {
        let staleness:Staleness?
        let tagSets:[TagSet]?

        init(staleness:Staleness?, tagSets:[TagSet]?)
        {
            self.staleness = staleness
            // normalize empty list to `nil`, to simplify filtering algorithm
            self.tagSets = tagSets.flatMap { $0.isEmpty ? nil : $0 }
        }
    }
}
extension MongoTopology.Eligibility
{
    init(replicas:__shared MongoTopology.Replicas,
        heartbeatFrequency:Milliseconds,
        maxStaleness:Seconds?,
        tagSets:[MongoTopology.TagSet]?)
    {
        self.init(staleness: maxStaleness.flatMap
            {
                .init(replicas: replicas,
                    heartbeatFrequency: heartbeatFrequency,
                    maxStaleness: $0)
            },
            tagSets: tagSets)
    }
}
extension MongoTopology.Eligibility
{
    func select(among candidates:[MongoTopology.Server<MongoTopology.Replica>],
        else fallback:MongoChannel? = nil)
        -> Result<MongoChannel, MongoTopology.EligibilityError>
    {
        var candidates:[MongoTopology.Server<MongoTopology.Replica>] = candidates
        var unsuitable:[MongoTopology.Rejection<MongoTopology.Unsuitable>] =
            self.staleness?.filter(candidates: &candidates) ?? []

        if  let tagSets:[MongoTopology.TagSet] = self.tagSets
        {
            for tagSet:MongoTopology.TagSet in tagSets
            {
                for candidate:MongoTopology.Server<MongoTopology.Replica> in candidates
                    where tagSet ~= candidate.connection.metadata.tags
                {
                    return .success(candidate.connection.channel)
                }
            }

            // no candidates matched!
            if  let fallback:MongoChannel
            {
                return .success(fallback)
            }
            for candidate:MongoTopology.Server<MongoTopology.Replica> in candidates
            {
                unsuitable.append(.init(reason: .tags(candidate.connection.metadata.tags),
                    host: candidate.host))
            }
        }
        else if let channel:MongoChannel = candidates.first?.connection.channel ?? fallback
        {
            return .success(channel)
        }

        return .failure(.init(unsuitable: unsuitable))
    }
}
