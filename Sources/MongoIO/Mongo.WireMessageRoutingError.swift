import MongoWire

extension Mongo
{
    public
    struct WireMessageRoutingError:Error
    {
        let request:Mongo.WireMessageIdentifier

        init(unknown request:Mongo.WireMessageIdentifier)
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
