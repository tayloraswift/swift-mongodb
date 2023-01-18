import MongoWire

extension MongoChannel
{
    public
    struct DisconnectionError:Equatable, Error
    {
        public
        init()
        {
        }
    }
}
extension MongoChannel.DisconnectionError:CustomStringConvertible
{
    public
    var description:String
    {
        "Connection closed while awaiting reply from server."
    }
}
