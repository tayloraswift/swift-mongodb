import MongoWire

extension MongoChannel
{
    public
    struct SocketError:Equatable, Error
    {
        public
        let request:MongoWire.MessageIdentifier

        public
        init(awaiting request:MongoWire.MessageIdentifier)
        {
            self.request = request
        }
    }
}
extension MongoChannel.SocketError:CustomStringConvertible
{
    public
    var description:String
    {
        "Socket closed by peer while awaiting response for message (id: \(self.request))."
    }
}
