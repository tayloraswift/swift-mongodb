import MongoWire

extension MongoChannel
{
    public
    struct TimeoutError:Equatable, Error
    {
        public
        let request:MongoWire.MessageIdentifier
        public
        let duration:Duration?

        public
        init(awaiting request:MongoWire.MessageIdentifier, for duration:Duration? = nil)
        {
            self.request = request
            self.duration = duration
        }
    }
}
extension MongoChannel.TimeoutError:CustomStringConvertible
{
    public
    var description:String
    {
        if let duration:Duration = self.duration
        {
            return "timed out while awaiting response for message (id: \(self.request), duration: \(duration))"
        }
        else
        {
            return "channel shut down while awaiting response for message (id: \(self.request))"
        }
    }
}
