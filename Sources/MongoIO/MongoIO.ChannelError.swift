extension MongoIO
{
    @frozen public
    enum ChannelError:Error
    {
        /// The channel experienced some sort of IO error. The caller
        /// should generally retry the request if desired.
        case io(any Error, written:Bool)
        /// The channel was closed because the task awaiting the relevant
        /// request was cancelled, either due to task cancellation, or
        /// network timeout.
        case cancelled(Cancellation)
        /// The channel was closed because a task besides the one awaiting
        /// the relevant request cancelled the request, due to some
        /// condition external to the caller.
        case crosscancelled(any Error)
    }
}
// extension MongoIO.ChannelError:CustomStringConvertible
// {
//     public
//     var description:String
//     {
//         switch self
//         {
//         case .timeout:
//             return """
//             Command execution failed due to timeout.
//             """
        
//         case .cancelled:
//             return """
//             Command execution failed because the calling task was cancelled.
//             """
        
//         case .crosscancelled(let error):
//             return """
//             Command execution failed because the connection was interrupted while \
//             awaiting reply from server.
//             """
        
//         case .network(let error, sent: false):
//             return """
//             Command execution failed before sending it over the connection. \
//             (\(error))
//             """
        
//         case .network(let error, sent: true):
//             return """
//             Command execution failed after senting it over the connection. \
//             (\(error))
//             """
//         }
//     }
// }
