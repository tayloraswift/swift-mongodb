import MongoChannel
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo.Connection
{
    struct Bootstrap
    {
        let channel:ClientBootstrap
        let _credentials:Mongo.Credentials?,
            _appname:String?
        let host:Mongo.Host
        
        init(channel:ClientBootstrap,
            _credentials:Mongo.Credentials?,
            _appname:String?,
            host:Mongo.Host)
        {
            self.channel = channel
            self._credentials = _credentials
            self._appname = _appname
            self.host = host
        }
    }
}
extension Mongo.Connection.Bootstrap
{
    func channel(to host:Mongo.Host,
        by deadline:Mongo.ConnectionDeadline) async throws -> MongoChannel
    {
        // TODO: apply deadline to NIO channel construction
        let channel:MongoChannel = .init(try await self.channel.connect(
            host: host.name,
            port: host.port).get())
        
        switch await channel.establish(credentials: self._credentials,
            appname: self._appname,
            by: deadline)
        {
        case .success(_):
            return channel
        
        case .failure(let error):
            await channel.close()
            throw error
        }
    }
}
