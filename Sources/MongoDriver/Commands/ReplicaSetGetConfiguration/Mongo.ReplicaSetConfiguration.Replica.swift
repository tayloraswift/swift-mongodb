import OrderedCollections

extension Mongo.ReplicaSetConfiguration
{
    @frozen public
    struct Replica:Equatable, Sendable
    {
        public
        let rights:Rights
        public
        let votes:Int
        public
        let tags:OrderedDictionary<String, String>

        public
        init(rights:Rights, votes:Int, tags:OrderedDictionary<String, String> = [:])
        {
            self.rights = rights
            self.votes = votes
            self.tags = tags
        }
    }
}
