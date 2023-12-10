extension Mongo
{
    @frozen public
    enum ReplyError:Equatable, Error
    {
        /// The server returned an error that lacks an error code.
        case uncoded(message:String)
    }
}
