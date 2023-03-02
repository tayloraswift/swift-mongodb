import Durations
import MongoIO
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo
{
    struct ConnectorFactory:Sendable
    {
        // TODO: need a better way to handle TLS certificates,
        // should probably cache certificate loading...
        private
        let _certificatePath:String?
        private
        let executor:any EventLoopGroup
        private
        let resolver:DNS.Connection?
        
        /// The name of the application.
        let appname:String?
        
        init(certificatePath:String?,
            executor:any EventLoopGroup,
            resolver:DNS.Connection?,
            appname:String?)
        {
            self._certificatePath = certificatePath
            self.resolver = resolver
            self.executor = executor
            self.appname = appname
        }
    }
}
extension Mongo.ConnectorFactory
{
    func callAsFunction<Authenticator>(authenticator:Authenticator,
        timeout:Milliseconds,
        host:Mongo.Host) -> Mongo.Connector<Authenticator>
    {
        .init(authenticator: authenticator,
            bootstrap: self.bootstrap(timeout: timeout, host: host),
            timeout: timeout,
            appname: appname,
            host: host)
    }
}
extension Mongo.ConnectorFactory
{
    private
    func bootstrap(timeout:Milliseconds, host:Mongo.Host) -> ClientBootstrap
    {
        .init(group: self.executor)
            .resolver(self.resolver)
            .channelOption(ChannelOptions.Types.ConnectTimeoutOption.init(), 
                value: .milliseconds(timeout.rawValue))
            .channelOption(ChannelOptions.Types.SocketOption.init(
                    level: Int.init(SOL_SOCKET),
                    name: SO_REUSEADDR), 
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
