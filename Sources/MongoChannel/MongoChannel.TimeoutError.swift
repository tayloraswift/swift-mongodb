import MongoWire

extension MongoChannel
{
    public
    struct TimeoutError:Equatable, Error
    {
        public
        let request:MongoWire.MessageIdentifier?

        public
        init(awaiting request:MongoWire.MessageIdentifier? = nil)
        {
            self.request = request
        }
    }
}
extension MongoChannel.TimeoutError:CustomStringConvertible
{
    public
    var description:String
    {
        if let request:MongoWire.MessageIdentifier = self.request
        {
            return "Timed out while awaiting response for message (id: \(request))."
        }
        else
        {
            return "Timed out before request could be sent."
        }
    }
}
