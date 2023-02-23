import Durations
import Heartbeats
import MongoChannel
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo
{
    struct MonitorConnector:Sendable
    {
        let heartbeatInterval:Milliseconds

        let credentialCache:CredentialCache
        let credentials:Credentials?
        let parameters:Connector.Parameters
        let pool:ConnectionPool.Parameters

        init(heartbeatInterval:Milliseconds,
            credentialCache:Mongo.CredentialCache,
            credentials:Mongo.Credentials?,
            parameters:Connector.Parameters,
            pool:ConnectionPool.Parameters)
        {
            self.heartbeatInterval = heartbeatInterval
            self.credentialCache = credentialCache
            self.credentials = credentials
            self.parameters = parameters
            self.pool = pool
        }
    }
}
extension Mongo.MonitorConnector
{
    var client:Mongo.ClientMetadata
    {
        .init(application: self.credentialCache.application)
    }
}
extension Mongo.MonitorConnector
{
    /// Sets up a TCP channel to the given host alongside a heartbeat that
    /// will stop if the channel is closed (for any reason).
    func connect(to host:Mongo.Host) async throws -> Mongo.MonitorConnection
    {
        let heartbeat:Heartbeat = .init(interval: .milliseconds(self.heartbeatInterval))
        let channel:MongoChannel = .init(try await self.parameters.bootstrap(for: host).connect(
            host: host.name,
            port: host.port).get())
        
        channel.whenClosed
        {
            //  when the checker task is cancelled, it will also close the
            //  connection again, which will be a no-op.
            switch $0
            {
            case .success(()):
                heartbeat.heart.stop()
            case .failure(let error):
                heartbeat.heart.stop(throwing: error)
            }
        }

        return .init(heartbeat: heartbeat, channel:  channel)
    }
}
