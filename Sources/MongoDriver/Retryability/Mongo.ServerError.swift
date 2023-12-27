import TraceableErrors

extension Mongo
{
    public
    struct ServerError:Equatable, Error
    {
        public
        let message:String
        public
        let code:Code

        public
        init(_ code:Code, message:String)
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
        "ServerError (\(self.code))"
    }
}
extension Mongo.ServerError:Mongo.RetryableError
{
    public
    var isRetryable:Bool
    {
        self.code.indicatesRetryability
    }
}
