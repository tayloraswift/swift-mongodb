import Durations
import Heartbeats
import MongoChannel
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
        let credentials:Credentials?
        let resolver:DNS.Connection?
        let executor:any EventLoopGroup
        public
        let appname:String?

        public
        init(certificatePath:String? = nil,
            credentials:Credentials?,
            resolver:DNS.Connection? = nil,
            executor:any EventLoopGroup,
            appname:String? = nil)
        {
            self.certificatePath = certificatePath
            self.credentials = credentials
            self.resolver = resolver
            self.executor = executor
            self.appname = appname
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
        heartbeatInterval:Milliseconds = 1000,
        timeout:Mongo.ConnectionTimeout = .init(milliseconds: 5000),
        run body:(Mongo.SessionPool) async throws -> Success) async rethrows -> Success
    {
        let monitor:Mongo.Monitor = .init(.init(hosts: seedlist),
            heartbeatInterval: heartbeatInterval,
            certificatePath: self.certificatePath,
            credentials: self.credentials,
            resolver: self.resolver,
            executor: self.executor,
            timeout: timeout,
            appname: self.appname)
        
        let pool:Mongo.SessionPool = .init(cluster: monitor.cluster)
        do
        {
            let success:Success = try await body(pool)
            await monitor.cluster.end(sessions: await pool.drain())
            await monitor.stop()
            return success
        }
        catch let error
        {
            await monitor.cluster.end(sessions: await pool.drain())
            await monitor.stop()
            throw error
        }
    }
}
