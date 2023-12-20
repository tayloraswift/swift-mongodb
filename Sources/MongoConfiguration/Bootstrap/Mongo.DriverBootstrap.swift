import Durations
import MongoClusters
import NIOCore

extension Mongo
{
    /// A driver configuration, which can be used to create session pools.
    public
    struct DriverBootstrap:Sendable
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
        init<Login>(locator:some Mongo.ServiceLocator<Login>,
            options:DriverOptions<Login.Authentication> = .init())
            where Login:Mongo.LoginMode
        {
            let login:Login = .init(options.authentication)

            self.credentials = login.credentials(
                userinfo: locator.userinfo,
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
