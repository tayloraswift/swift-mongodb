import MongoWire

extension MongoChannel
{
    public
    struct InterruptError:Equatable, Error
    {
        public
        init()
        {
        }
    }
}
extension MongoChannel.InterruptError:CustomStringConvertible
{
    public
    var description:String
    {
        "Interrupted while awaiting reply from server."
    }
}
