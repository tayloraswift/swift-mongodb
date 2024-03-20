infix operator /? : MultiplicationPrecedence

extension Mongo
{
    public
    protocol ServiceLocator<Login>
    {
        associatedtype Login:LoginMode

        var userinfo:Login.Userinfo { get }
        var database:Login.Database? { get }

        var domains:SeedingMethod { get }
    }
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
