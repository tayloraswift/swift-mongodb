import Durations
import MongoChannel

extension MongoTopology
{
    public
    struct Eligibility:Equatable, Sendable
    {
        public
        let maxStaleness:Seconds?
        public
        let tagSets:[TagSet]?

        @inlinable public
        init()
        {
            self.maxStaleness = nil
            self.tagSets = nil
        }

        @inlinable public
        init(maxStaleness:Seconds?, tagSets:[TagSet]?)
        {
            // normalize, to simplify filtering algorithm
            self.maxStaleness = maxStaleness.flatMap { $0 < 0 ? nil : $0 }
            self.tagSets = tagSets.flatMap { $0.isEmpty ? nil : $0 }
        }
    }
}
extension MongoTopology.Eligibility
{
    public
    func diagnose(unsuitable candidates:[MongoTopology.Server<MongoTopology.Candidate>])
        -> [MongoTopology.Host: MongoTopology.Unsuitable]
    {
        if let maxStaleness:Milliseconds = self.maxStaleness?.milliseconds
        {
            return candidates.reduce(into: [:])
            {
                $0[$1.host] = $1.connection.metadata.staleness > maxStaleness ?
                    .stale($1.connection.metadata.staleness) :
                    .tags($1.connection.metadata.tags)
            }
        }
        else
        {
            return candidates.reduce(into: [:])
            {
                $0[$1.host] = .tags($1.connection.metadata.tags)
            }
        }
    }
}
