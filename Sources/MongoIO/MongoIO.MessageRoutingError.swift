import MongoWire

extension MongoIO
{
    public
    struct MessageRoutingError:Error
    {
        let request:MongoWire.MessageIdentifier

        init(unknown request:MongoWire.MessageIdentifier)
        {
            self.request = request
        }
    }
}
extension MongoIO.MessageRoutingError:CustomStringConvertible
{
    public
    var description:String
    {
        "Received response to unknown request (id: \(self.request))."
    }
}
