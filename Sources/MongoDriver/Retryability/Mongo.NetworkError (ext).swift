import MongoIO
import TraceableErrors

extension Mongo.NetworkError:TraceableError
{
    public
    var notes:[String]
    {
        switch self.provenance
        {
        case nil:
            return []

        case .crosscancellation:
            return ["error propogated via cross-cancellation"]
        }
    }
}
extension Mongo.NetworkError:MongoRetryableError
{
    public
    var isRetryable:Bool { true }
}
