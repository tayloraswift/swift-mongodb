extension Mongo
{
    /// Under this discovery mode, the driver will query a domain name
    /// server to obtain a list of MongoDB servers. This type also serves
    /// as a namespace for DNS-related functionality.
    @frozen public
    enum DNS
    {
    }
}
extension Mongo.DNS:MongoDiscoveryMode
{
    @inlinable public static
    subscript(hostname:String, port:Int?) -> Mongo.SeedingMethod
    {
        .dns(.init(name: hostname, port: port ?? 53))
    }
}
