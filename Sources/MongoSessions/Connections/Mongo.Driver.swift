import NIOCore

extension Mongo
{
    /// A driver configuration, which can be used to create ``SessionPool``s.
    ///
    /// Drivers are value types. Overwriting a driver’s settings doesn’t
    /// affect previously-created session pools, it only affects session pools
    /// you create with that configuration in the future.
    public
    struct Driver:Sendable
    {
        // TODO: need a better way to handle TLS certificates,
        // should probably cache certificate loading...
        var _certificatePath:String?

        public
        var credentials:Credentials?
        public
        var appname:String?

        /// The amount of time the driver will wait for a reply from a server.
        public
        var timeout:Milliseconds

        let resolver:DNS.Connection?,
            executor:any EventLoopGroup
        
        let clock:ContinuousClock

        public
        init(certificatePath:String? = nil,
            credentials:Credentials?,
            resolver:DNS.Connection? = nil,
            executor:any EventLoopGroup,
            timeout:Milliseconds = .seconds(10),
            appname:String? = nil)
        {
            self._certificatePath = certificatePath
            self.credentials = credentials
            self.resolver = resolver
            self.executor = executor
            self.timeout = timeout
            self.appname = appname

            self.clock = .init()
        }
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
