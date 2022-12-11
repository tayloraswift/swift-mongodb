extension Mongo
{
    struct SessionMedium
    {
        let connection:Mongo.Connection
        let timeout:Mongo.Minutes
    }
}
