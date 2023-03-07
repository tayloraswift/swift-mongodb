infix operator /? : MultiplicationPrecedence

public
protocol MongoServiceLocator<LoginMode>
{
    associatedtype LoginMode:MongoLoginMode

    var userinfo:LoginMode { get }
    var database:LoginMode.Database? { get }

    var domains:Mongo.SeedingMethod { get }
}
extension MongoServiceLocator
{
    @inlinable public static
    func /? (self:__owned Self,
        configure:(inout Mongo.DriverOptions<LoginMode.Authentication>) throws -> ())
        rethrows -> Mongo.DriverBootstrap
    {
        var options:Mongo.DriverOptions<LoginMode.Authentication> = .init()
        try configure(&options)
        return .init(locator: self, options: options)
    }
}
