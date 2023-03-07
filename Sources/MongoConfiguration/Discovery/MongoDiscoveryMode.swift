/// A way to discover members of a MongoDB deployment.
public
protocol MongoDiscoveryMode
{
    associatedtype Seedlist = Mongo.Seedlist
    
    static
    subscript(seedlist:Seedlist) -> Mongo.SeedingMethod { get }
}
