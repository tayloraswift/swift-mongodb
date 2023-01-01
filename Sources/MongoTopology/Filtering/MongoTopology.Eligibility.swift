import Durations
import MongoChannel

extension MongoTopology
{
    public
    struct Eligibility
    {
        public
        let maxStaleness:Milliseconds?
        public
        let tagSets:[TagSet]?

        @inlinable public
        init()
        {
            self.maxStaleness = nil
            self.tagSets = nil
        }

        public
        init(maxStaleness:Seconds?, tagSets:[TagSet]?)
        {
            // normalize, to simplify filtering algorithm
            self.maxStaleness = maxStaleness.flatMap { $0 < 0 ? nil : $0.milliseconds }
            self.tagSets = tagSets.flatMap { $0.isEmpty ? nil : $0 }
        }
    }
}
extension MongoTopology.Eligibility
{
    func diagnose(unsuitable candidates:[MongoTopology.Server<MongoTopology.Candidate>])
        -> [MongoTopology.Rejection<MongoTopology.Unsuitable>]
    {
        if let maxStaleness:Milliseconds = self.maxStaleness
        {
            return candidates.compactMap
            {
                .init(reason: $0.connection.metadata.staleness > maxStaleness ?
                        .stale($0.connection.metadata.staleness) :
                        .tags($0.connection.metadata.tags),
                    host: $0.host)
            }
        }
        else
        {
            return candidates.map
            {
                .init(reason: .tags($0.connection.metadata.tags), host: $0.host)
            }
        }
    }
}
