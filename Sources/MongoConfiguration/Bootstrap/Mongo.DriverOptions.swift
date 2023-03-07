import Durations
import NIOCore

extension Mongo
{
    @frozen public
    struct DriverOptions<Authentication>
    {
        public
        var authentication:Authentication?

        public
        var executors:NIOEventLoopGroupProvider

        public
        var appname:String?
        public
        var connectionTimeout:Milliseconds
        public
        var connectionPoolSize:ClosedRange<Int>
        public
        var connectionPoolRate:Int
        public
        var monitorInterval:Milliseconds
        public
        var topology:TopologyHint?
        public
        var tls:TLS?

        //  Note: this does not have default arguments to prevent us
        //  from forgetting to forward properties
        @inlinable internal
        init(authentication:Authentication? = nil,
            executors:NIOEventLoopGroupProvider = .createNew,
            appname:String? = nil,
            connectionTimeout:Milliseconds = .milliseconds(10_000),
            connectionPoolSize:ClosedRange<Int> = 0 ... 100,
            connectionPoolRate:Int = 2,
            monitorInterval:Milliseconds = .milliseconds(10_000),
            topology:TopologyHint? = nil,
            tls:TLS? = nil)
        {
            self.authentication = authentication

            self.executors = executors

            self.appname = appname
            self.connectionTimeout = connectionTimeout
            self.connectionPoolSize = connectionPoolSize
            self.connectionPoolRate = connectionPoolRate
            self.monitorInterval = monitorInterval
            self.topology = topology
            self.tls = tls
        }
    }
}
extension Mongo.DriverOptions
{
    @available(*, unavailable, renamed: "appname")
    public
    var appName:String? { fatalError() }

    @available(*, unavailable, renamed: "authentication")
    public
    var authMechanism:Authentication? { fatalError() }
    
    @available(*, unavailable, renamed: "connectionTimeout")
    public
    var connectTimeoutMS:Milliseconds { fatalError() }
    
    @available(*, unavailable, renamed: "monitorInterval")
    public
    var heartbeatFrequencyMS:Milliseconds { fatalError() }
    
    @available(*, unavailable, renamed: "tls")
    public
    var ssl:Mongo.TLS? { fatalError() }
    
    @available(*, unavailable,
        message: "specify an authentication database as a URI path component instead.")
    public
    var authSource:Int { fatalError() }
    
    @available(*, unavailable, message: "use the 'connectionPoolSize' option instead.")
    public
    var minPoolSize:Int { fatalError() }
    
    @available(*, unavailable, message: "use the 'connectionPoolSize' option instead.")
    public
    var maxPoolSize:Int { fatalError() }

    @available(*, unavailable, message: "use the 'topology' hint option instead.")
    public
    var replicaSet:String? { fatalError() }
}
