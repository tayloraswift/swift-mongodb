import BSON

extension Mongo
{
    /// The MongoDB `hello` command, also known as `isMaster`.
    ///
    /// This command is internal because it must not be used with sessions.
    struct Hello:Sendable
    {
        let client:ClientMetadata?
        let user:Mongo.Namespaced<String>?

        init(client:ClientMetadata? = nil,
            user:Mongo.Namespaced<String>?)
        {
            self.client = client
            self.user = user
        }
    }
}
extension Mongo.Hello
{
    /// The string `"hello"`.
    @inlinable public static
    var type:Mongo.CommandType { .hello }
}
extension Mongo.Hello:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson[.init(Self.type)] = true
        bson["client"] = self.client
        bson["saslSupportedMechs"] = self.user
    }
}
