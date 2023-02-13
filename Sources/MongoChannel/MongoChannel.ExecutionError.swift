extension MongoChannel
{
    @frozen public
    enum ExecutionError:Error
    {
        case timeout
        case network(error:NetworkError)
    }
}
extension MongoChannel.ExecutionError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .timeout:
            return "Command execution timed out by the driver while awaiting reply from server."
        case .network(error: let error):
            return error.description
        }
    }
}
