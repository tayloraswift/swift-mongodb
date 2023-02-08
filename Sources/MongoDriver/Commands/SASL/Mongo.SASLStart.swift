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
extension Mongo.SASLStart:MongoCommand
{
    typealias Response = Mongo.SASLResponse
    
    /// The string [`"saslStart"`]().
    static
    var name:String
    {
        "saslStart"
    }

    public
    var fields:BSON.Fields
    {
        .init
        {
            $0[Self.name] = true
            $0["mechanism"] = self.mechanism
            $0["payload"] = self.scram.message.base64
            $0["options"] = .init
            {
                $0["skipEmptyExchange"] = true
            }
        }
    }
}
