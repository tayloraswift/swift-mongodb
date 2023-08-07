import TraceableErrors
import MongoClusters

extension Mongo
{
    public
    struct ConnectionPoolDrainedError:Error
    {
        public
        let underlying:any Error
        public
        let host:Host

        public
        init(because error:any Error, host:Host)
        {
            self.underlying = error
            self.host = host
        }
    }
}
extension Mongo.ConnectionPoolDrainedError:Equatable
{
    public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.host == rhs.host &&
        lhs.underlying == rhs.underlying
    }
}
extension Mongo.ConnectionPoolDrainedError:TraceableError
{
    public
    var notes:[String]
    {
        [
            """
            while filling connection pool for '\(self.host)'
            """
        ]
    }
}
extension Mongo.ConnectionPoolDrainedError:MongoRetryableError
{
    public
    var isRetryable:Bool { true }
}
