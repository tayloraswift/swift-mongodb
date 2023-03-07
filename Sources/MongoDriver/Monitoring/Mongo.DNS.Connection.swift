import NIOCore
import NIOPosix

extension Mongo.DNS
{
    public
    enum Connection:Sendable
    {
    }
}
extension Mongo.DNS.Connection:Resolver
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
extension Mongo.DNS.Connection
{
    func srv(_ host:Mongo.Host) async throws -> [Mongo.Host] 
    {
        fatalError("unimplemented")
    }
}
