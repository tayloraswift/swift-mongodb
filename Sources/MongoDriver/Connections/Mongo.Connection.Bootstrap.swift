import MongoChannel
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo.Connection
{
    struct Bootstrap
    {
        let channel:ClientBootstrap
        let credentials:Mongo.Credentials?
        let cache:Mongo.CredentialCache
        let host:Mongo.Host
        
        init(channel:ClientBootstrap,
            credentials:Mongo.Credentials?,
            cache:Mongo.CredentialCache,
            host:Mongo.Host)
        {
            self.channel = channel
            self.credentials = credentials
            self.cache = cache
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
