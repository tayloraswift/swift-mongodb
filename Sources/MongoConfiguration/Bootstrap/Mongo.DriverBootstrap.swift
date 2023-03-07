import Durations
import NIOCore

extension Mongo
{
    /// A driver configuration, which can be used to create session pools.
    public
    struct DriverBootstrap
    {
        public
        let credentials:Credentials?
        public
        let seeding:SeedingMethod

        public
        let executors:NIOEventLoopGroupProvider

        public
        let appname:String?
        public
        let connectionTimeout:Milliseconds
        public
        let connectionPoolSize:ClosedRange<Int>
        public
        let connectionPoolRate:Int
        public
        let monitorInterval:Milliseconds
        public
        let topology:TopologyHint?

        public
        let tls:TLS

        @inlinable internal
        init<Authentication>(
            locator:some MongoServiceLocator<some MongoLoginMode<Authentication>>,
            options:DriverOptions<Authentication> = .init())
        {
            self.credentials = locator.userinfo.credentials(
                authentication: options.authentication,
                database: locator.database)
            self.seeding = locator.domains

            self.executors = options.executors

            self.appname = options.appname
            self.connectionTimeout = options.connectionTimeout
            self.connectionPoolSize = options.connectionPoolSize
            self.connectionPoolRate = options.connectionPoolRate
            self.monitorInterval = options.monitorInterval
            self.topology = options.topology

            switch self.seeding
            {
            case .direct:
                self.tls = options.tls ?? .disabled
            
            case .dns:
                self.tls = options.tls ?? .enabled
            }
        }
    }
}
