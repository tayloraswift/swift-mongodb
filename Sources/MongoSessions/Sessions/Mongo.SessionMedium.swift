import MongoChannel

extension Mongo
{
    struct SessionMedium:Sendable
    {
        let channel:MongoChannel
        let ttl:Mongo.Minutes
    }
}
