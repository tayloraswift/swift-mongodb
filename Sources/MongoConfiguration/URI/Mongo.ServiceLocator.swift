infix operator /? : MultiplicationPrecedence

extension Mongo
{
    public
    typealias ServiceLocator = _MongoServiceLocator
}

@available(*, deprecated, renamed: "Mongo.ServiceLocator")
public
typealias MongoServiceLocator = Mongo.ServiceLocator

public
protocol _MongoServiceLocator<Login>
{
    associatedtype Login:Mongo.LoginMode

    var userinfo:Login.Userinfo { get }
    var database:Login.Database? { get }

    var domains:Mongo.SeedingMethod { get }
}
extension Mongo.ServiceLocator
{
    @inlinable public static
    func /? (self:__owned Self,
        configure:(inout Mongo.DriverOptions<Login.Authentication>) throws -> ())
        rethrows -> Mongo.DriverBootstrap
    {
        var options:Mongo.DriverOptions<Login.Authentication> = .init()
        try configure(&options)
        return .init(locator: self, options: options)
    }
}
