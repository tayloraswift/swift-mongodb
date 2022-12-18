import BSONEncoding

extension Mongo
{
    struct Hello:Sendable
    {
        let client:ClientMetadata?
        let user:User?

        init(client:ClientMetadata? = nil, user:User?)
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
