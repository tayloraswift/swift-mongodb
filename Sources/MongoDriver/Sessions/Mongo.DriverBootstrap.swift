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
        private
        let connectorFactory:ConnectorFactory
        private
        let authenticator:Authenticator

        public
        init(certificatePath:String? = nil,
            credentials:Credentials?,
            executor:any EventLoopGroup,
            resolver:DNS.Connection? = nil,
            appname:String? = nil)
        {
            self.connectorFactory = .init(certificatePath: certificatePath,
                executor: executor,
                resolver: resolver,
                appname: appname)
            self.authenticator = .init(credentials: credentials)
        }
    }
}

extension Mongo.DriverBootstrap
{
    public
    var credentials:Mongo.Credentials?
    {
        self.authenticator.credentials
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
        connectionTimeout:Milliseconds = 5000,
        monitorInterval:Milliseconds = 1000,
        logger:Mongo.Logger? = nil,
        run body:(Mongo.SessionPool) async throws -> Success) async rethrows -> Success
    {
        let deployment:Mongo.Deployment = .init(connectionTimeout: connectionTimeout,
            logger: logger)
        let monitors:Mongo.MonitorPool = .init(connectionPoolSettings: .init(),
            connectorFactory: self.connectorFactory,
            authenticator: self.authenticator,
            deployment: deployment)
        
        #if compiler(<5.8)
        async
        let __:Void = monitors.start(interval: monitorInterval, seedlist: seedlist)
        #else
        async
        let _:Void = monitors.start(interval: monitorInterval, seedlist: seedlist)
        #endif
        
        let sessions:Mongo.SessionPool = .init(deployment: deployment)
        do
        {
            let success:Success = try await body(sessions)
            await deployment.end(sessions: await sessions.drain())
            return success
        }
        catch let error
        {
            await deployment.end(sessions: await sessions.drain())
            throw error
        }
    }
}
