import BSON
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
        let tags:OrderedDictionary<BSON.Key, String>

        public
        init(rights:Rights, votes:Int, tags:OrderedDictionary<BSON.Key, String> = [:])
        {
            self.rights = rights
            self.votes = votes
            self.tags = tags
        }
    }
}
