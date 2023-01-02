import BSONEncoding
import SCRAM

extension Mongo
{
    struct SASLContinue
    {
        let conversation:Int32
        let message:SCRAM.Message
    }
}
extension Mongo.SASLContinue:MongoDatabaseCommand
{
    typealias Response = Mongo.SASLResponse
    
    func encode(to bson:inout BSON.Fields)
    {
        bson["saslContinue"] = true
        bson["conversationId"] = self.conversation
        bson["payload"] = self.message.base64
    }
}