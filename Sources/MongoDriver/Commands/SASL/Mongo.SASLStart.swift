import BSONEncoding
import SCRAM

extension Mongo
{
    /// The MongoDB `saslStart` command.
    ///
    /// This command is internal because it must not be used with sessions.
    struct SASLStart
    {
        let mechanism:Mongo.Authentication.SASL
        let scram:SCRAM.Start

        init(mechanism:Mongo.Authentication.SASL, scram:SCRAM.Start)
        {
            self.mechanism = mechanism
            self.scram = scram
        }
    }
}
extension Mongo.SASLStart:MongoChannelCommand
{
    /// The string [`"saslStart"`]().
    static
    var name:String
    {
        "saslStart"
    }

    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = true
        bson["mechanism"] = self.mechanism
        bson["payload"] = self.scram.message.base64
        bson["options"] = .init
        {
            $0["skipEmptyExchange"] = true
        }
    }
}
