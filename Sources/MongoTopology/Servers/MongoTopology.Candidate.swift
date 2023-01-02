import Durations
import MongoChannel

extension MongoTopology
{
    public
    struct Candidate:Sendable
    {
        let staleness:Milliseconds
        let tags:[String: String]
    }
}
extension [MongoTopology.Server<MongoTopology.Candidate>]
{
    func select(by eligibility:MongoTopology.Eligibility) -> MongoChannel?
    {
        let fresh:[MongoTopology.Server<MongoTopology.Candidate>]
        if let maxStaleness:Milliseconds = eligibility.maxStaleness?.milliseconds
        {
            fresh = self.filter
            {
                $0.connection.metadata.staleness <= maxStaleness
            }
        }
        else
        {
            fresh = self
        }
        return fresh.first(matching: eligibility.tagSets)
    }
    private
    func first(matching tagSets:[MongoTopology.TagSet]?) -> MongoChannel?
    {
        guard let tagSets:[MongoTopology.TagSet]
        else
        {
            return self.first?.connection.channel
        }

        for tagSet:MongoTopology.TagSet in tagSets
        {
            for candidate:MongoTopology.Server<MongoTopology.Candidate> in self
                where tagSet ~= candidate.connection.metadata.tags
            {
                return candidate.connection.channel
            }
        }
        return nil
    }
}
