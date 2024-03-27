import Durations
import MongoIO
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo
{
    struct ConnectorFactory:Sendable
    {
        private
        let executors:any EventLoopGroup
        /// The name of the application.
        private
        let appname:String?
        private
        let tls:TLS

        init(executors:any EventLoopGroup, appname:String?, tls:TLS)
        {
            self.executors = executors
            self.appname = appname
            self.tls = tls
        }
    }
}
extension Mongo.ConnectorFactory
{
    func callAsFunction<Authenticator>(authenticator:Authenticator,
        timeout:Mongo.NetworkTimeout,
        host:Mongo.Host) -> Mongo.Connector<Authenticator>
    {
        .init(authenticator: authenticator,
            bootstrap: self.bootstrap(timeout: timeout.milliseconds, host: host),
            timeout: timeout,
            appname: self.appname,
            host: host)
    }
}
extension Mongo.ConnectorFactory
{
    private
    func bootstrap(timeout:Milliseconds, host:Mongo.Host) -> ClientBootstrap
    {
        .init(group: self.executors)
            .channelOption(ChannelOptions.Types.ConnectTimeoutOption.init(),
                value: .milliseconds(timeout.rawValue))
            .channelOption(ChannelOptions.Types.SocketOption.init(
                    //  Do not remove the integer conversion, it is needed on Linux.
                    level: .init(SOL_SOCKET),
                    name: SO_REUSEADDR),
                value: 1)
            .channelInitializer
        {
            (channel:any Channel) in

            let parser:Mongo.WireMessageParser = .init()
            let router:Mongo.WireMessageRouter = .init()

            guard case .enabled = self.tls
            else
            {
                return channel.pipeline.addHandlers(parser, router)
            }
            do
            {
                let tls:NIOSSLClientHandler = try .init(context: .init(
                        configuration: .clientDefault),
                    serverHostname: host.name)
                return channel.pipeline.addHandlers(tls, parser, router)
            }
            catch let error
            {
                return channel.eventLoop.makeFailedFuture(error)
            }
        }
    }
}
