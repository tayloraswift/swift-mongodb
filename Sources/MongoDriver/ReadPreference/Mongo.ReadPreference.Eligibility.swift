import Durations

extension Mongo.ReadPreference
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
extension Mongo.ReadPreference.Eligibility
{
    func diagnose(unsuitable candidates:[Mongo.Server<Mongo.ServerTable.ReplicaQuality>])
        -> [Mongo.Host: Mongo.Unsuitable]
    {
        if let maxStaleness:Milliseconds = self.maxStaleness?.milliseconds
        {
            candidates.reduce(into: [:])
            {
                $0[$1.host] = $1.metadata.staleness > maxStaleness ?
                    .stale($1.metadata.staleness) :
                    .tags($1.metadata.tags)
            }
        }
        else
        {
            candidates.reduce(into: [:])
            {
                $0[$1.host] = .tags($1.metadata.tags)
            }
        }
    }
}
