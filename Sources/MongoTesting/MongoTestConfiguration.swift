import MongoDB
import NIOPosix

public
protocol MongoTestConfiguration<Login> where Login:Mongo.LoginMode
{
    associatedtype Login

    static
    var userinfo:Login.Userinfo { get }

    static
    var members:Mongo.Seedlist { get }

    static
    func configure(options:inout Mongo.DriverOptions<Login.Authentication>)

    static
    func bootstrap(on threads:MultiThreadedEventLoopGroup) -> Mongo.DriverBootstrap
}
extension MongoTestConfiguration
{
    /// Does nothing.
    public static
    func configure(options:inout Mongo.DriverOptions<Login.Authentication>)
    {
    }
}
extension MongoTestConfiguration<Mongo.Guest>
{
    /// Returns the empty tuple.
    public static
    var userinfo:Void { () }

    public static
    func bootstrap(on threads:MultiThreadedEventLoopGroup) -> Mongo.DriverBootstrap
    {
        MongoDB / Self.members /?
        {
            $0.executors = .shared(threads)
            configure(options: &$0)
        }
    }
}
extension MongoTestConfiguration<Mongo.User>
{
    public static
    func bootstrap(on threads:MultiThreadedEventLoopGroup) -> Mongo.DriverBootstrap
    {
        MongoDB / Self.userinfo * Self.members /?
        {
            $0.executors = .shared(threads)
            configure(options: &$0)
        }
    }
}
