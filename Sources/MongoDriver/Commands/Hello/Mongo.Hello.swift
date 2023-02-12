import BSONEncoding

extension Mongo
{
    /// The MongoDB `hello` command, also known as `isMaster`.
    ///
    /// This command is internal because it must not be used with sessions.
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
extension Mongo.Hello:MongoChannelCommand
{
    /// The string [`"hello"`]().
    @inlinable public static
    var name:String
    {
        "hello"
    }

    /// `Hello` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = true
        bson["client"] = self.client
        bson["saslSupportedMechs"] = self.user
    }
}
