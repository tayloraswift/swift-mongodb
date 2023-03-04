import Durations

extension Mongo.ServerTable
{
    public
    struct ReplicaQuality:Sendable
    {
        let staleness:Milliseconds
        let tags:[String: String]
    }
}
extension [Mongo.Server<Mongo.ServerTable.ReplicaQuality>]
{
    func select(by eligibility:Mongo.ReadPreference.Eligibility) -> Mongo.ConnectionPool?
    {
        let fresh:[Mongo.Server<Mongo.ServerTable.ReplicaQuality>]
        if let maxStaleness:Milliseconds = eligibility.maxStaleness?.milliseconds
        {
            fresh = self.filter
            {
                $0.metadata.staleness <= maxStaleness
            }
        }
        else
        {
            fresh = self
        }
        return fresh.first(matching: eligibility.tagSets)
    }
    private
    func first(matching tagSets:[Mongo.ReadPreference.TagSet]?) -> Mongo.ConnectionPool?
    {
        guard let tagSets:[Mongo.ReadPreference.TagSet]
        else
        {
            return self.first?.pool
        }

        for tagSet:Mongo.ReadPreference.TagSet in tagSets
        {
            for candidate:Mongo.Server<Mongo.ServerTable.ReplicaQuality> in self
                where tagSet ~= candidate.metadata.tags
            {
                return candidate.pool
            }
        }
        return nil
    }
}
