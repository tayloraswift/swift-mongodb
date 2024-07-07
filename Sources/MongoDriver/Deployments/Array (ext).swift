import BSON
import UnixTime

extension [Mongo.Server<Mongo.ReplicaQuality>]
{
    func select(by eligibility:Mongo.ReadPreference.Eligibility) -> Mongo.ConnectionPool?
    {
        let fresh:[Mongo.Server<Mongo.ReplicaQuality>]
        if let maxStaleness:Seconds = eligibility.maxStaleness
        {
            fresh = self.filter
            {
                $0.metadata.staleness <= Milliseconds.init(maxStaleness)
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
            for candidate:Mongo.Server<Mongo.ReplicaQuality> in self
                where tagSet ~= candidate.metadata.tags
            {
                return candidate.pool
            }
        }
        return nil
    }
}
