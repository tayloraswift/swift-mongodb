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
        init(_ code:Int32?, message:String)
        {
            self.message = message
            self.code = code
        }
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
