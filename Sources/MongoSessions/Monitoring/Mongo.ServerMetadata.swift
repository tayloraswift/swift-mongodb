import Durations
import MongoTopology

extension Mongo
{
    struct ServerMetadata
    {
        let ttl:Minutes
        let type:MongoTopology.Server

        init(ttl:Minutes, type:MongoTopology.Server)
        {
            self.ttl = ttl
            self.type = type
        }
    }
}
