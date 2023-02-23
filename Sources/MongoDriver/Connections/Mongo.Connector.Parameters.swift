import MongoIO
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo.Connector
{
    struct Parameters
    {
        // TODO: need a better way to handle TLS certificates,
        // should probably cache certificate loading...
        let _certificatePath:String?

        let resolver:DNS.Connection?,
            executor:any EventLoopGroup
        
        init(certificatePath:String?,
            resolver:DNS.Connection?,
            executor:any EventLoopGroup)
        {
            self._certificatePath = certificatePath
            self.resolver = resolver
            self.executor = executor
        }
    }
}
extension Mongo.Connector.Parameters
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

            let decoder:ByteToMessageHandler<MongoIO.MessageDecoder> = .init(.init())
            let router:MongoIO.MessageRouter = .init()

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
