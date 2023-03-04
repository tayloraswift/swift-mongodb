import MongoIO
import TraceableErrors

extension Mongo
{
    @frozen public
    struct NetworkError:Error
    {
        public
        let underlying:any Error
        public
        let provenance:NetworkErrorProvenance?

        @inlinable public
        init(underlying:any Error, provenance:NetworkErrorProvenance?)
        {
            self.underlying = underlying
            self.provenance = provenance
        }
    }
}
extension Mongo.NetworkError
{
    public
    init(triaging error:MongoIO.ChannelError) throws
    {
        switch error
        {
        case .io(let error, written: _):
            self.init(underlying: error, provenance: nil)
        
        case .cancelled(.timeout):
            throw Mongo.TimeoutError.driver(written: true)
        
        case .cancelled(.cancel):
            throw CancellationError.init()
        
        case .crosscancelled(let error):
            self.init(underlying: error, provenance: .crosscancellation)
        }
    }
}
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
