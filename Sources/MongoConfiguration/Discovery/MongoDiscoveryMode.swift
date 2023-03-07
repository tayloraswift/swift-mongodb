/// A way to discover members of a MongoDB deployment.
public
protocol MongoDiscoveryMode
{
    /// Creates a seedlist containing a single seed.
    static
    subscript(hostname:String, port:Int?) -> Mongo.SeedingMethod { get }
}
