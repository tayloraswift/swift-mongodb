import Durations

extension Mongo.Servers
{
    public
    struct Candidate:Sendable
    {
        let staleness:Milliseconds
        let tags:[String: String]
    }
}
extension [Mongo.Server<Mongo.Servers.Candidate>]
{
    func select(by eligibility:Mongo.ReadPreference.Eligibility) -> Mongo.ConnectionPool?
    {
        let fresh:[Mongo.Server<Mongo.Servers.Candidate>]
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
            for candidate:Mongo.Server<Mongo.Servers.Candidate> in self
                where tagSet ~= candidate.metadata.tags
            {
                return candidate.pool
            }
        }
        return nil
    }
}
