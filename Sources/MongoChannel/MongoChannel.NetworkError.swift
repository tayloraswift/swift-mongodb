import MongoWire

extension MongoChannel
{
    @frozen public
    enum NetworkError:Error
    {
        case interrupted
        case disconnected
        case other(any Error)
    }
}
extension MongoChannel.NetworkError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .interrupted:
            return "Command execution interrupted while awaiting reply from server."
        case .disconnected:
            return "Command execution failed because the connection closed while awaiting reply from server."
        case .other(let error):
            return "\(error)"
        }
    }
}
