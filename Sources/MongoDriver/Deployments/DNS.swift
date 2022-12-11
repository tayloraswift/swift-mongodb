import NIOCore
import NIOPosix

/// A placeholder for DNS-related functionality.
public
enum DNS
{
    public
    enum Connection:Sendable
    {
    }
}
extension DNS.Connection:Resolver
{
    public
    func initiateAQuery(host:String, port:Int) -> EventLoopFuture<[SocketAddress]>
    {
        fatalError("unimplemented")
    }
    public
    func initiateAAAAQuery(host:String, port:Int) -> EventLoopFuture<[SocketAddress]>
    {
        fatalError("unimplemented")
    }
    public
    func cancelQueries()
    {
        fatalError("unimplemented")
    }
}
extension DNS.Connection
{
    func srv(_ host:Mongo.Host) async throws -> [Mongo.Host] 
    {
        fatalError("unimplemented")
    }
}
