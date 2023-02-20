import BSONDecoding
import SCRAM

extension Mongo
{
    struct SASLResponse:Sendable
    {
        private
        let conversation:Int32
        let message:SCRAM.Message
        let done:Bool
    }
}
extension Mongo.SASLResponse
{
    func command(message:SCRAM.Message) -> Mongo.SASLContinue
    {
        .init(conversation: self.conversation, message: message)
    }
}
extension Mongo.SASLResponse:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<String, some RandomAccessCollection<UInt8>>) throws
    {
        self.conversation = try bson["conversationId"].decode(to: Int32.self)
        self.message = try bson["payload"].decode
        {
            switch $0
            {
            case .string(let utf8):
                return .init(base64: utf8.slice)
            case .binary(let binary):
                return .init(base64: binary.slice)
            default:
                throw BSON.TypecastError<String>.init(invalid: $0.type)
            }
        }
        self.done = try bson["done"].decode(to: Bool.self)
    }
}
