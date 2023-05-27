import Durations
import MongoConfiguration
import NIOCore
import NIOPosix

// extension Mongo.DriverBootstrap
// {
//     public
//     var credentials:Mongo.Credentials?
//     {
//         self.authenticator.credentials
//     }
// }
extension Mongo.DriverBootstrap
{
    private
    func withExecutors<Success>(
        do operation:(any EventLoopGroup) async throws -> Success) async rethrows -> Success
    {
        switch self.executors
        {
        case .createNew:
            let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 1)
            do
            {
                let success:Success = try await operation(executors)
                try? await executors.shutdownGracefully()
                return success
            }
            catch let error
            {
                try? await executors.shutdownGracefully()
                throw error
            }

        case .shared(let executors):
            return try await operation(executors)
        }
    }
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
    func withSessionPool<Success>(logger:Mongo.Logger? = nil,
        run body:(Mongo.SessionPool) async throws -> Success) async rethrows -> Success
    {
        try await self.withExecutors
        {
            let connectorFactory:Mongo.ConnectorFactory = .init(executors: $0,
                appname: self.appname,
                tls: self.tls)
            let authenticator:Mongo.Authenticator = .init(credentials: self.credentials)

            let deployment:Mongo.Deployment = .init(connectionTimeout: self.connectionTimeout,
                logger: logger)
            let monitors:Mongo.MonitorPool = .init(connectionPoolSettings: .init(
                    size: self.connectionPoolSize,
                    rate: self.connectionPoolRate),
                connectorFactory: connectorFactory,
                authenticator: authenticator,
                deployment: deployment)

            async
            let _:Void = monitors.start(from: self.seeding,
                interval: self.monitorInterval,
                topology: self.topology)

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
}
