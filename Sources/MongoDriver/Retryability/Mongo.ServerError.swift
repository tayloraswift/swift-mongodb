import TraceableErrors

extension Mongo
{
    public
    struct ServerError:Equatable, Error
    {
        public
        let message:String
        public
        let code:Code?

        public
        init(_ code:Code?, message:String)
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
extension Mongo.ServerError:MongoRetryableError
{
    public
    var isRetryable:Bool
    {
        self.code?.indicatesRetryability ?? false
    }
}
