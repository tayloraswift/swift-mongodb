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

    @inlinable public
    func SRV(_ username:String,
        _ password:String) -> Mongo.URI.Base<Mongo.User, Mongo.DNS>
    {
        .init(userinfo: .init(username: username, password: password))
    }
}

extension Mongo.URI.Base
{
    @_disfavoredOverload
    @inlinable public
    subscript(hostname:String, port:Int? = nil) -> Mongo.URI.Authority<LoginMode>
    {
        .init(userinfo: self.userinfo, domains: DiscoveryMode[hostname, port])
    }
    @inlinable public
    subscript(hostname:String, port:Int? = nil) -> Mongo.DriverBootstrap
    {
        .init(locator: self[hostname, port])
    }
}
extension Mongo.URI.Base where DiscoveryMode == Mongo.DirectSeeding
{
    @_disfavoredOverload
    @inlinable public
    subscript(hosts:Mongo.Seedlist) -> Mongo.URI.Authority<LoginMode>
    {
        .init(userinfo: self.userinfo, domains: .direct(hosts))
    }
    @inlinable public
    subscript(hosts:Mongo.Seedlist) -> Mongo.DriverBootstrap
    {
        .init(locator: self[hosts])
    }
}
