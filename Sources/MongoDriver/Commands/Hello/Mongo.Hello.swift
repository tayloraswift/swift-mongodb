import BSONEncoding

extension Mongo
{
    struct Hello:Sendable
    {
        let client:ClientMetadata?
        let user:Mongo.Namespaced<String>?

        init(client:ClientMetadata? = nil, user:Mongo.Namespaced<String>?)
        {
            self.client = client
            self.user = user
        }
    }
}
extension Mongo.Hello:MongoCommand
{
    func encode(to bson:inout BSON.Fields)
    {
        bson["hello"] = true
        bson["client"] = self.client
        bson["saslSupportedMechs"] = self.user
    }
}
