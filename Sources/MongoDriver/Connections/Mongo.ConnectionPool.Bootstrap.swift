import Durations
import Heartbeats
import MongoChannel
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo.ConnectionPool
{
    struct Bootstrap:Sendable
    {
        let heartbeatInterval:Milliseconds
        // TODO: need a better way to handle TLS certificates,
        // should probably cache certificate loading...
        let _certificatePath:String?

        let credentials:Mongo.Credentials?
        let cache:Mongo.CredentialCache

        let resolver:DNS.Connection?,
            executor:any EventLoopGroup
        
        let timeout:Mongo.ConnectionTimeout

        init(heartbeatInterval:Milliseconds,
            certificatePath:String?,
            credentials:Mongo.Credentials?,
            cache:Mongo.CredentialCache,
            resolver:DNS.Connection?,
            executor:any EventLoopGroup,
            timeout:Mongo.ConnectionTimeout)
        {
            self.heartbeatInterval = heartbeatInterval
            self._certificatePath = certificatePath
            self.credentials = credentials
            self.cache = cache
            self.resolver = resolver
            self.executor = executor
            self.timeout = timeout
        }
    }
}
extension Mongo.ConnectionPool.Bootstrap
{
    func bootstrap(for host:Mongo.Host) -> ClientBootstrap
    {
        .init(group: self.executor)
            .resolver(self.resolver)
            .channelOption(
                ChannelOptions.socket(SocketOptionLevel.init(SOL_SOCKET), SO_REUSEADDR), 
                value: 1)
            .channelInitializer
        { 
            (channel:any Channel) in

            let decoder:ByteToMessageHandler<MongoChannel.MessageDecoder> = .init(.init())
            let router:MongoChannel.MessageRouter = .init()

            guard let certificatePath:String = self._certificatePath
            else
            {
                return channel.pipeline.addHandlers(decoder, router)
            }
            do 
            {
                var configuration:TLSConfiguration = .clientDefault
                configuration.trustRoots = NIOSSLTrustRoots.file(certificatePath)
                
                let tls:NIOSSLClientHandler = try .init(
                    context: .init(configuration: configuration), 
                    serverHostname: host.name)
                return channel.pipeline.addHandlers(tls, decoder, router)
            } 
            catch let error
            {
                return channel.eventLoop.makeFailedFuture(error)
            }
        }
    }
}
