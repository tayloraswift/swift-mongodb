import MongoWire

extension Mongo
{
    public
    struct WireMessageRoutingError:Error
    {
        let request:MongoWire.MessageIdentifier

        init(unknown request:MongoWire.MessageIdentifier)
        {
            self.request = request
        }
    }
}
extension Mongo.WireMessageRoutingError:CustomStringConvertible
{
    public
    var description:String
    {
        "Received response to unknown request (id: \(self.request))."
    }
}
