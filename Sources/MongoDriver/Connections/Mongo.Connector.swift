import MongoChannel
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo
{
    struct Connector
    {
        let bootstrap:ClientBootstrap
        let credentials:Credentials?
        let cache:CredentialCache
        let host:Host
        
        init(bootstrap:ClientBootstrap,
            credentials:Credentials?,
            cache:CredentialCache,
            host:Host)
        {
            self.bootstrap = bootstrap
            self.credentials = credentials
            self.cache = cache
            self.host = host
        }
    }
}
extension Mongo.Connector
{
    func channel(to host:Mongo.Host,
        by deadline:Mongo.ConnectionDeadline) async throws -> MongoChannel
    {
        // TODO: apply deadline to NIO channel construction
        let channel:MongoChannel = .init(try await self.bootstrap.connect(
            host: host.name,
            port: host.port).get())
        
        switch await self.cache.establish(channel, credentials: self.credentials, by: deadline)
        {
        case .success(_):
            return channel
        
        case .failure(let error):
            await channel.close()
            throw error
        }
    }
}
