import MongoWire

extension MongoChannel
{
    public
    struct TimeoutError:Equatable, Error
    {
        let sent:Bool

        public
        init(sent:Bool = false)
        {
            self.sent = sent
        }
    }
}
extension MongoChannel.TimeoutError:CustomStringConvertible
{
    public
    var description:String
    {
        self.sent
            ? "Timed out while awaiting reply from server."
            : "Timed out before request could be sent."
    }
}
