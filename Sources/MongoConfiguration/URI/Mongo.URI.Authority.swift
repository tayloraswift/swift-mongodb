import MongoABI

extension Mongo.URI
{
    /// The first two significant components of a connection string URI.
    /// It contains login credentials (which may be empty), and a list of
    /// domains. To append a path component to it, use the ``Authority//(_:_:) [1DYBW]``
    /// operator, which returns a ``Location``.
    @frozen public
    struct Authority<Login>:Sendable where Login:Mongo.LoginMode
    {
        public
        let userinfo:Login.Userinfo
        public
        let domains:Mongo.SeedingMethod

        @inlinable public
        init(userinfo:Login.Userinfo, domains:Mongo.SeedingMethod)
        {
            self.userinfo = userinfo
            self.domains = domains
        }
    }
}
extension Mongo.URI.Authority<Mongo.User>
{
    @_disfavoredOverload
    @inlinable public static
    func / (self:Self, path:Mongo.Database) -> Mongo.URI.Location
    {
        .init(userinfo: self.userinfo, domains: self.domains, path: path)
    }

    @inlinable public static
    func / (self:Self, path:Mongo.Database) -> Mongo.DriverBootstrap
    {
        .init(locator: self / path)
    }
}
extension Mongo.URI.Authority:Mongo.ServiceLocator
{
    @inlinable public
    var database:Login.Database? { nil }
}
