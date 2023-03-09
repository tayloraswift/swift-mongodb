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
extension Mongo.SASLContinue
{
    static
    var type:Mongo.CommandType { .saslContinue }
}
extension Mongo.SASLContinue:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson[.init(Self.type)] = true
        bson["conversationId"] = self.conversation
        bson["payload"] = self.message.base64
    }
}
