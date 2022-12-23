import Durations

extension Mongo
{
    struct ServerMetadata
    {
        let ttl:Minutes
        let type:Mongo.Server

        init(ttl:Minutes, type:Mongo.Server)
        {
            self.ttl = ttl
            self.type = type
        }
    }
}
