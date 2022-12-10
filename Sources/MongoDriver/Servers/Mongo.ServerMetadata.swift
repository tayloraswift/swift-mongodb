extension Mongo
{
    struct ServerMetadata
    {
        let sessionTimeout:Mongo.Minutes
        let type:Mongo.Server

        init(sessionTimeout:Mongo.Minutes, type:Mongo.Server)
        {
            self.sessionTimeout = sessionTimeout
            self.type = type
        }
    }
}
