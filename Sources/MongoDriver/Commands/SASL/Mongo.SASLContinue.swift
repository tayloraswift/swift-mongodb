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
extension Mongo.SASLContinue:MongoCommand
{
    typealias Response = Mongo.SASLResponse
    
    /// The string [`"saslContinue"`]().
    static
    var name:String
    {
        "saslContinue"
    }

    public
    var fields:BSON.Fields
    {
        .init
        {
            $0[Self.name] = true
            $0["conversationId"] = self.conversation
            $0["payload"] = self.message.base64
        }
    }
}
