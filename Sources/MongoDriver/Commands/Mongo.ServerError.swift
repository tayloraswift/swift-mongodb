import TraceableErrors

extension Mongo
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
extension Mongo.ServerError:CustomStringConvertible
{
    public
    var description:String
    {
        self.message
    }
}
extension Mongo.ServerError:NamedError
{
    public
    var name:String
    {
        self.code.map { "ServerError (\($0))" } ?? "ServerError"
    }
}
