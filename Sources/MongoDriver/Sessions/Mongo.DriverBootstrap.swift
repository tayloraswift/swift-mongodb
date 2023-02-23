import Durations
import NIOCore

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
        let certificatePath:String?

        public
        let application:String?
        public
        let credentials:Credentials?

        let resolver:DNS.Connection?
        let executor:any EventLoopGroup

        public
        init(certificatePath:String? = nil,
            application:String? = nil,
            credentials:Credentials?,
            resolver:DNS.Connection? = nil,
            executor:any EventLoopGroup)
        {
            self.certificatePath = certificatePath
            self.application = application
            self.credentials = credentials
            self.resolver = resolver
            self.executor = executor
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
    ///
    /// Never escape sessions, connections, or connection pools from within the
    /// closure parameter. This method cannot return until all such objects have
    /// been deinitialized.
    public
    func withSessionPool<Success>(seedlist:Set<Mongo.Host>,
        heartbeatInterval:Milliseconds = 1000,
        timeout:Mongo.ConnectionTimeout = .init(milliseconds: 5000),
        logger:Mongo.Logger? = nil,
        run body:(Mongo.SessionPool) async throws -> Success) async rethrows -> Success
    {
        let connector:Mongo.MonitorConnector = .init(
            heartbeatInterval: heartbeatInterval,
            credentialCache: .init(application: application),
            credentials: self.credentials,
            parameters: .init(certificatePath: certificatePath,
                resolver: resolver,
                executor: executor),
            pool: .init())
        
        let deployment:Mongo.Deployment = .init(timeout: timeout, logger: logger)
        let monitor:Mongo.Monitor = .init(.init(hosts: seedlist),
            deployment: deployment,
            connector: connector)
        
        let pool:Mongo.SessionPool = .init(deployment: deployment)
        do
        {
            let success:Success = try await body(pool)
            await deployment.end(sessions: await pool.drain())
            await monitor.stop()
            return success
        }
        catch let error
        {
            await deployment.end(sessions: await pool.drain())
            await monitor.stop()
            throw error
        }
    }
}
