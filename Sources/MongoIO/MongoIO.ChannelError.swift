extension MongoIO
{
    @frozen public
    enum ChannelError:Error
    {
        case cancellation(CancellationError)
        case network(any Error, sent:Bool)
    }
}
extension MongoIO.ChannelError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .cancellation(.timeout):
            return """
            Command execution timed out by the driver while awaiting reply from server.
            """
        case .cancellation(.cancel):
            return """
            Command execution failed because the connection was interrupted while \
            awaiting reply from server.
            """
        
        case .network(let error, sent: false):
            return """
            Command execution failed before sending it over the connection. \
            (\(error))
            """
        
        case .network(let error, sent: true):
            return """
            Command execution failed after senting it over the connection. \
            (\(error))
            """
        }
    }
}
