import Durations
import Heartbeats
import MongoChannel
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo
{
    /// A driver configuration, which can be used to create ``SessionPool``s.
    ///
    /// Drivers are value types. Overwriting a driver’s settings doesn’t
    /// affect previously-created session pools, it only affects session pools
    /// you create with that configuration in the future.
    public
    struct DriverBootstrap:Sendable
    {
        /// The amount of time the driver will wait for a reply from a server.
        public
        var commandTimeout:Milliseconds
        // TODO: need a better way to handle TLS certificates,
        // should probably cache certificate loading...
        var _certificatePath:String?

        public
        var credentials:Credentials?
        public
        var appname:String?


        let resolver:DNS.Connection?,
            executor:any EventLoopGroup

        public
        init(commandTimeout:Milliseconds = .seconds(10),
            certificatePath:String? = nil,
            credentials:Credentials?,
            resolver:DNS.Connection? = nil,
            executor:any EventLoopGroup,
            appname:String? = nil)
        {
            self.commandTimeout = commandTimeout
            self._certificatePath = certificatePath
            self.credentials = credentials
            self.resolver = resolver
            self.executor = executor
            self.appname = appname
        }
    }
}
extension Mongo.DriverBootstrap
{
    /// Sets up a TCP channel to the given host that will stop the given
    /// heartbeat if the channel is closed (for any reason). The heart
    /// will not be stopped if the channel cannot be created in the first
    /// place; the caller is responsible for disposing of the heartbeat
    /// if this constructor throws an error.
    func channel(to host:Mongo.Host, attaching heart:Heart) async throws -> MongoChannel
    {
        .init(try await self.bootstrap(for: host).connect(
                host: host.name,
                port: host.port).get(),
            attaching: heart)
    }

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
            let router:MongoChannel.MessageRouter = .init(
                timeout: .milliseconds(self.commandTimeout))

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
extension Mongo.DriverBootstrap
{
    /// Sets up a session pool and executes the given closure passing the pool
    /// as a parameter. Waits for the closure to return, then attempts to gracefully
    /// drain and shut down the session pool, returning only when the shutdown
    /// procedure has either completed or failed.
    ///
    /// When this method returns, all sockets have been closed and it is safe to
    /// immediately re-initialize another session pool, without needing to worry
    /// about any “hangover effects” from the previous session pool.
    ///
    /// Shutdown failures are silent, as they only imply a failure to log out of
    /// active server sessions, which is inevitable in situations such as a network
    /// outage. This means that if the passed `body` closure throws an error, that
    /// error will be the same error observed by the caller of this method.
    public
    func withSessionPool<Success>(seedlist:Set<Mongo.Host>,
        _ body:(Mongo.SessionPool) async throws -> Success) async rethrows -> Success
    {
        let monitor:Mongo.Monitor = .init(bootstrap: self)
        await monitor.seed(with: seedlist)
        let pool:Mongo.SessionPool = .init(cluster: monitor.cluster)
        do
        {
            let success:Success = try await body(pool)
            await monitor.cluster.end(sessions: await pool.drain())
            await monitor.unseed()
            return success
        }
        catch let error
        {
            await monitor.cluster.end(sessions: await pool.drain())
            await monitor.unseed()
            throw error
        }
    }
}
