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
extension Mongo.SASLContinue:MongoChannelCommand
{
    /// The string [`"saslContinue"`]().
    static
    var name:BSON.UniversalKey
    {
        "saslContinue"
    }

    func encode(to bson:inout BSON.DocumentEncoder<BSON.UniversalKey>)
    {
        bson[Self.name] = true
        bson["conversationId"] = self.conversation
        bson["payload"] = self.message.base64
    }
}
