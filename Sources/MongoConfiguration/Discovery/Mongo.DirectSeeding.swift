extension Mongo
{
    /// Under this discovery mode, the driver will use a predefined list
    /// of MongoDB servers to connect to a deployment.
    @frozen public
    enum DirectSeeding
    {
    }
}
extension Mongo.DirectSeeding:MongoDiscoveryMode
{
    @inlinable public static
    subscript(hostname:String, port:Int?) -> Mongo.SeedingMethod
    {
        .direct(.init(host: .init(name: hostname, port: port)))
    }
}
