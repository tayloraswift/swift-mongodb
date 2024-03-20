import MongoClusters

extension Mongo
{
    /// A way to discover members of a MongoDB deployment.
    public
    protocol DiscoveryMode
    {
        associatedtype Seedlist = Mongo.Seedlist

        static
        subscript(seedlist:Self.Seedlist) -> SeedingMethod { get }
    }
}
