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
            return """
            Command execution timed out by the driver while awaiting reply from server.
            """
        
        case .network(error: .disconnected):
            return """
            Command execution failed because the connection was closed while awaiting reply \
            from server.
            """
        
        case .network(error: .interrupted):
            return """
            Command execution failed because the connection was interrupted while \
            awaiting reply from server.
            """
        
        case .network(error: .perished(let error)):
            return """
            Command execution failed because it could not be sent over the connection.\
            (\(error))
            """
        
        case .network(error: .other(let error)):
            return """
            Command execution failed because the connection errored while awaiting reply \
            from server. (\(error))
            """
        }
    }
}
