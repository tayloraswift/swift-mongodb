extension Mongo
{
    struct ServerMetadata
    {
        let ttl:Mongo.Minutes
        let type:Mongo.Server

        init(ttl:Mongo.Minutes, type:Mongo.Server)
        {
            self.ttl = ttl
            self.type = type
        }
    }
}
