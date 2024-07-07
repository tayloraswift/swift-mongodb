import UnixTime

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
            self.maxStaleness = maxStaleness.flatMap { $0 < .zero ? nil : $0 }
            self.tagSets = tagSets.flatMap { $0.isEmpty ? nil : $0 }
        }
    }
}
extension Mongo.ReadPreference.Eligibility
{
    func diagnose(
        unsuitable:[Mongo.Server<Mongo.ReplicaQuality>]) -> [Mongo.Host: Mongo.Unsuitable]
    {
        if  let maxStaleness:Seconds = self.maxStaleness
        {
            unsuitable.reduce(into: [:])
            {
                $0[$1.host] = $1.metadata.staleness > Milliseconds.init(maxStaleness) ?
                    .stale($1.metadata.staleness) :
                    .tags($1.metadata.tags)
            }
        }
        else
        {
            unsuitable.reduce(into: [:])
            {
                $0[$1.host] = .tags($1.metadata.tags)
            }
        }
    }
}
