import Heartbeats
import NIOCore
import NIOPosix
import NIOSSL

extension Mongo
{
    public
    struct Driver:Sendable
    {
        // TODO: need a better way to handle TLS certificates,
        // should probably cache certificate loading...
        var _certificatePath:String?
        public
        var credentials:Credentials?

        /// The amount of time the driver will wait for a reply from a server.
        public
        var timeout:Milliseconds

        private 
        let resolver:DNS.Connection?,
            loops:any EventLoopGroup
        
        let clock:ContinuousClock

        public
        init(certificatePath:String? = nil,
            credentials:Credentials?,
            resolver:DNS.Connection? = nil,
            timeout:Milliseconds = .seconds(10),
            loops:any EventLoopGroup) 
        {
            self._certificatePath = certificatePath
            self.credentials = credentials
            self.resolver = resolver
            self.timeout = timeout
            self.loops = loops

            self.clock = .init()
        }
    }
}
extension Mongo.Driver
{
    /// Sets up a TCP channel to the given host that will stop the given
    /// heartbeat if the channel is closed (for any reason). The heart
    /// will not be stopped if the channel cannot be created in the first
    /// place; the caller is responsible for disposing of the heartbeat
    /// if this constructor throws an error.
    func connect(to host:Mongo.Host, heart:Heart) async throws -> Mongo.Connection
    {
        let bootstrap:ClientBootstrap = .init(group: self.loops)
            .resolver(self.resolver)
            .channelOption(ChannelOptions.socket(SocketOptionLevel.init(SOL_SOCKET), SO_REUSEADDR), 
                value: 1)
            .channelInitializer 
        { 
            (channel:any Channel) in

            let wire:ByteToMessageHandler<Mongo.MessageDecoder> = .init(.init())
            let router:Mongo.MessageRouter = .init(timeout: self.timeout)

            guard let certificatePath:String = self._certificatePath
            else
            {
                return channel.pipeline.addHandlers(wire, router)
            }
            do 
            {
                var configuration:TLSConfiguration = .clientDefault
                configuration.trustRoots = NIOSSLTrustRoots.file(certificatePath)
                
                let tls:NIOSSLClientHandler = try .init(
                    context: .init(configuration: configuration), 
                    serverHostname: host.name)
                return channel.pipeline.addHandlers(tls, wire, router)
            } 
            catch let error
            {
                return channel.eventLoop.makeFailedFuture(error)
            }
        }

        let channel:any Channel = try await bootstrap.connect(
            host: host.name,
            port: host.port).get()
        
        channel.closeFuture.whenComplete
        {
            //  when the checker task is cancelled, it will also close the
            //  connection again, which will be a no-op.
            switch $0
            {
            case .success(()):
                heart.stop()
            case .failure(let error):
                heart.stop(throwing: error)
            }
        }
        
        return .init(channel: channel, heart: heart)
    }
}
extension Mongo.Driver
{
    public
    func seeded<Success>(with seeds:Set<Mongo.Host>,
        _ body:(Mongo.SessionPool) async throws -> Success) async rethrows -> Success
    {
        let monitor:Mongo.TopologyMonitor = .init(driver: self)
        await monitor.seed(with: seeds)
        let pool:Mongo.SessionPool = .init(monitor)
        do
        {
            let success:Success = try await body(pool)
            await monitor.end(sessions: await pool.drain())
            await monitor.unseed()
            return success
        }
        catch let error
        {
            await monitor.end(sessions: await pool.drain())
            await monitor.unseed()
            throw error
        }
    }
}
