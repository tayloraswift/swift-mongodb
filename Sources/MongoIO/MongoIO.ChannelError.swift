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
