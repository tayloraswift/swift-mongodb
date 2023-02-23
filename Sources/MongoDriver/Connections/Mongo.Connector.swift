import MongoChannel
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo
{
    struct Connector
    {
        /// The connection timeout.
        /// The service monitor also uses this to compute deadlines for server
        /// monitoring operations.
        private
        let timeout:ConnectionTimeout

        private
        let bootstrap:ClientBootstrap
        private
        let credentials:Credentials?
        private
        let cache:CredentialCache
        private
        let host:Host
        
        init(timeout:ConnectionTimeout,
            bootstrap:ClientBootstrap,
            credentials:Credentials?,
            cache:CredentialCache,
            host:Host)
        {
            self.timeout = timeout
            self.bootstrap = bootstrap
            self.credentials = credentials
            self.cache = cache
            self.host = host
        }
    }
}
extension Mongo.Connector
{
    func channel(to host:Mongo.Host) async throws -> MongoChannel
    {
        let deadline:Mongo.ConnectionDeadline = self.timeout.deadline(
            from: .now)
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
