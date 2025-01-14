import MongoDB
import NIOPosix
import UnixTime

extension Mongo
{
    protocol TestConfiguration<Login>:Sendable where Login:Mongo.LoginMode
    {
        associatedtype Login

        var userinfo:Login.Userinfo { get }
        var members:Mongo.Seedlist { get }
        var servers:[Mongo.ReadPreference] { get }

        func configure(options:inout Mongo.DriverOptions<Login.Authentication>)

        func bootstrap(on threads:MultiThreadedEventLoopGroup) -> Mongo.DriverBootstrap
    }
}
extension Mongo.TestConfiguration
{
    /// Does nothing.
    func configure(options:inout Mongo.DriverOptions<Login.Authentication>)
    {
    }
}
extension Mongo.TestConfiguration<Mongo.Guest>
{
    /// Returns the empty tuple.
    var userinfo:Void { () }

    func bootstrap(on threads:MultiThreadedEventLoopGroup) -> Mongo.DriverBootstrap
    {
        MongoDB / self.members /?
        {
            $0.executors = threads
            configure(options: &$0)
        }
    }
}
extension Mongo.TestConfiguration<Mongo.User>
{
    func bootstrap(on threads:MultiThreadedEventLoopGroup) -> Mongo.DriverBootstrap
    {
        MongoDB / self.userinfo * self.members /?
        {
            $0.executors = threads
            configure(options: &$0)
        }
    }
}
extension Mongo.TestConfiguration where Self == Mongo.SingleConfiguration
{
    static
    var single:Self
    {
        .init(
            userinfo: ("root", "80085"),
            members: ["mongo-single": 27017],
            servers: [.primary])
    }
}
extension Mongo.TestConfiguration where Self == Mongo.ReplicatedConfiguration
{
    static var replicatedWithLongerTimeout:Self
    {
        .replicated(connectionTimeout: .milliseconds(2000))
    }

    static var replicated:Self
    {
        .replicated(connectionTimeout: .milliseconds(1000))
    }

    private
    static func replicated(connectionTimeout:Milliseconds) -> Self
    {
        .init(
            connectionTimeout: connectionTimeout,
            members: [
                "mongo-0": 27017,
                "mongo-1": 27017,
                "mongo-2": 27017,
                "mongo-3": 27017,
                "mongo-4": 27017,
                "mongo-5": 27017,
                "mongo-6": 27017,
            ],
            servers: [
                .primary,
                //  We should be able to run these tests on a specific server.
                .nearest(tagSets: [["name": "B"]]),
                //  We should be able to run these tests on a secondary.
                .nearest(tagSets: [["name": "C"]]),
            ])
    }
}
