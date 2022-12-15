extension Mongo
{
    struct SessionMedium:Sendable
    {
        let connection:Mongo.Connection
        let ttl:Mongo.Minutes
    }
}
