import MongoClusters

extension Mongo
{
    /// A way to discover members of a MongoDB deployment.
    public
    typealias DiscoveryMode = _MongoDiscoveryMode
}

@available(*, deprecated, renamed: "Mongo.DiscoveryMode")
public
typealias MongoDiscoveryMode = Mongo.DiscoveryMode

/// The name of this protocol is ``Mongo.DiscoveryMode``.
public
protocol _MongoDiscoveryMode
{
    associatedtype Seedlist = Mongo.Seedlist

    static
    subscript(seedlist:Seedlist) -> Mongo.SeedingMethod { get }
}
