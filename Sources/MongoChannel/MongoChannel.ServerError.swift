import TraceableErrors

extension MongoChannel
{
    public
    struct ServerError:Equatable, Error
    {
        public
        let message:String
        public
        let code:Int32?

        public
        init(message:String, code:Int32?)
        {
            self.message = message
            self.code = code
        }
    }
}
extension MongoChannel.ServerError:CustomStringConvertible
{
    public
    var description:String
    {
        self.message
    }
}
extension MongoChannel.ServerError:NamedError
{
    public
    var name:String
    {
        self.code.map { "ServerError (\($0))" } ?? "ServerError"
    }
}
