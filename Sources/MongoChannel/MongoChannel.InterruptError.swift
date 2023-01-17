import MongoWire

extension MongoChannel
{
    public
    struct InterruptError:Equatable, Error
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
extension MongoChannel.InterruptError:CustomStringConvertible
{
    public
    var description:String
    {
        "Interrupted while awaiting response for message (id: \(self.request))."
    }
}
