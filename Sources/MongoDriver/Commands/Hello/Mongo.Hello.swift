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
extension Mongo.Hello:MongoCommand
{
    /// `Hello` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    /// The string [`"hello"`]().
    @inlinable public static
    var name:String
    {
        "hello"
    }

    public
    var fields:BSON.Fields
    {
        .init
        {
            $0[Self.name] = true
            $0["client"] = self.client
            $0["saslSupportedMechs"] = self.user
        }
    }

    public
    typealias Response = Mongo.HelloResponse
}
