import Durations
import BSONEncoding

extension Mongo
{
    /// The MongoDB `hello` command, also known as `isMaster`.
    ///
    /// This command is internal because it must not be used with sessions.
    struct Hello:Sendable
    {
        let client:ClientMetadata?
        let await:Milliseconds?
        let user:Mongo.Namespaced<String>?

        init(client:ClientMetadata? = nil,
            await:Milliseconds? = nil,
            user:Mongo.Namespaced<String>?)
        {
            self.client = client
            self.await = `await`
            self.user = user
        }
    }
}
extension Mongo.Hello
{
    /// The string [`"hello"`]().
    @inlinable public static
    var name:BSON.Key
    {
        "hello"
    }
}
extension Mongo.Hello:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson[Self.name] = true
        bson["client"] = self.client
        bson["maxAwaitTimeMS"] = self.await
        bson["saslSupportedMechs"] = self.user
    }
}
