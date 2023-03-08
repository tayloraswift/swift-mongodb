import BSONEncoding
import SCRAM

extension Mongo
{
    /// The MongoDB `saslStart` command.
    ///
    /// This command is internal because it must not be used with sessions.
    struct SASLStart
    {
        let mechanism:Authentication.SASL
        let scram:SCRAM.Start

        init(mechanism:Authentication.SASL, scram:SCRAM.Start)
        {
            self.mechanism = mechanism
            self.scram = scram
        }
    }
}
extension Mongo.SASLStart
{
    /// The string [`"saslStart"`]().
    static
    var name:BSON.Key
    {
        "saslStart"
    }
}
extension Mongo.SASLStart:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson[Self.name] = true
        bson["mechanism"] = self.mechanism
        bson["payload"] = self.scram.message.base64
        bson["options"]
        {
            $0["skipEmptyExchange"] = true
        }
    }
}
