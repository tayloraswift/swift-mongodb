extension Mongo.URI
{
    /// The first significant component of a connection string URI. It
    /// contains login credentials (which may be empty), and provides
    /// subscripts for building an ``Authority``.
    @frozen public
    struct Base<Login, Discovery>:Sendable
        where Login:Mongo.LoginMode, Discovery:Mongo.DiscoveryMode
    {
        public
        let userinfo:Login.Userinfo

        @inlinable public
        init(userinfo:Login.Userinfo)
        {
            self.userinfo = userinfo
        }
    }
}
extension Mongo.URI.Base<Mongo.Guest, Mongo.DirectSeeding>
{
    @inlinable public
    var SRV:Mongo.URI.Base<Mongo.Guest, Mongo.DNS>
    {
        .init(userinfo: ())
    }
}

extension Mongo.URI.Base where Login == Mongo.Guest
{
    @inlinable public static
    func / (base:Self, userinfo:Mongo.User.Userinfo) -> Mongo.URI.Base<Mongo.User, Discovery>
    {
        .init(userinfo: userinfo)
    }

    @_disfavoredOverload
    @inlinable public static
    func / (base:Self, domains:Discovery.Seedlist) -> Mongo.URI.Authority<Login>
    {
        .init(userinfo: base.userinfo, domains: Discovery[domains])
    }
    @inlinable public static
    func / (base:Self, domains:Discovery.Seedlist) -> Mongo.DriverBootstrap
    {
        .init(locator: base / domains)
    }
}
extension Mongo.URI.Base where Login == Mongo.User
{
    @_disfavoredOverload
    @inlinable public static
    func * (base:Self, domains:Discovery.Seedlist) -> Mongo.URI.Authority<Mongo.User>
    {
        .init(userinfo: base.userinfo, domains: Discovery[domains])
    }
    @inlinable public static
    func * (base:Self, domains:Discovery.Seedlist) -> Mongo.DriverBootstrap
    {
        .init(locator: base * domains)
    }
}
