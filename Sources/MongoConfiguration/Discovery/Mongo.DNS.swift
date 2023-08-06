import MongoClusters

extension Mongo
{
    /// Under this discovery mode, the driver will query a domain name
    /// server to obtain a list of MongoDB servers. This type also serves
    /// as a namespace for DNS-related functionality.
    @frozen public
    struct DNS
    {
        public
        let host:Host

        @inlinable public
        init(_ host:Host)
        {
            self.host = host
        }
    }
}
extension Mongo.DNS:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:String...)
    {
        if  arrayLiteral.count == 1
        {
            self.init(.init(name: arrayLiteral[0], port: 53))
        }
        else
        {
            fatalError("DNS seedlist literal must contain exactly one hostname.")
        }
    }
}
extension Mongo.DNS:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(String, Int)...)
    {
        if  dictionaryLiteral.count == 1
        {
            self.init(.init(name: dictionaryLiteral[0].0, port: dictionaryLiteral[0].1))
        }
        else
        {
            fatalError("DNS seedlist literal must contain exactly one host.")
        }
    }
}
extension Mongo.DNS:MongoDiscoveryMode
{
    @inlinable public static
    subscript(seed:Self) -> Mongo.SeedingMethod
    {
        .dns(seed)
    }
}
