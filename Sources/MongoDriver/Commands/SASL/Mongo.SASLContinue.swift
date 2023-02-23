import BSONEncoding
import SCRAM

extension Mongo
{
    /// The MongoDB `saslContinue` command.
    ///
    /// This command is internal because it must not be used with sessions.
    struct SASLContinue
    {
        let conversation:Int32
        let message:SCRAM.Message
    }
}
extension Mongo.SASLContinue:MongoDriverCommand
{
    /// The string [`"saslContinue"`]().
    static
    var name:BSON.Key
    {
        "saslContinue"
    }

    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson[Self.name] = true
        bson["conversationId"] = self.conversation
        bson["payload"] = self.message.base64
    }
}
