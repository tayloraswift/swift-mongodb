extension Mongo.URI
{
    /// The first significant component of a connection string URI. It
    /// contains login credentials (which may be empty), and provides
    /// subscripts for building an ``Authority``.
    @frozen public
    struct Base<LoginMode, DiscoveryMode>
        where LoginMode:MongoLoginMode, DiscoveryMode:MongoDiscoveryMode
    {
        public
        let userinfo:LoginMode

        @inlinable public
        init(userinfo:LoginMode)
        {
            self.userinfo = userinfo
        }
    }
}
extension Mongo.URI.Base:Sendable where LoginMode:Sendable
{
}
extension Mongo.URI.Base<Mongo.Guest, Mongo.DirectSeeding>
{
    @inlinable public
    var SRV:Mongo.URI.Base<Mongo.Guest, Mongo.DNS>
    {
        .init(userinfo: .init())
    }
}

extension Mongo.URI.Base where LoginMode.Authentication == Never
{
    @inlinable public static
    func / (base:Self, userinfo:
        (
            username:String,
            password:String
        ))  -> Mongo.URI.Base<Mongo.User, DiscoveryMode>
    {
        .init(userinfo: .init(username: userinfo.username, password: userinfo.password))
    }
    
    @_disfavoredOverload
    @inlinable public static
    func / (base:Self, domains:DiscoveryMode.Seedlist) -> Mongo.URI.Authority<LoginMode>
    {
        .init(userinfo: base.userinfo, domains: DiscoveryMode[domains])
    }
    @inlinable public static
    func / (base:Self, domains:DiscoveryMode.Seedlist) -> Mongo.DriverBootstrap
    {
        .init(locator: base / domains)
    }
}
extension Mongo.URI.Base where LoginMode.Authentication == Mongo.Authentication
{
    @_disfavoredOverload
    @inlinable public static
    func * (base:Self, domains:DiscoveryMode.Seedlist) -> Mongo.URI.Authority<LoginMode>
    {
        .init(userinfo: base.userinfo, domains: DiscoveryMode[domains])
    }
    @inlinable public static
    func * (base:Self, domains:DiscoveryMode.Seedlist) -> Mongo.DriverBootstrap
    {
        .init(locator: base * domains)
    }
}
