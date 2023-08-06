extension Mongo.Topology
{
    public
    struct Single
    {
        private
        var host:Mongo.Host
        //  This will never be nil under normal use cases. But specifying
        //  it like this makes the subscript’s semantics easier to understand.
        private
        var value:Mongo.ServerDescription<Mongo.Standalone, Owner>?

        init(host:Mongo.Host, metadata:Mongo.Standalone, owner:Owner)
        {
            self.host = host
            self.value = .connected(metadata, owner)
        }
    }
}
extension Mongo.Topology.Single:Sendable where Owner:Sendable
{
}
extension Mongo.Topology.Single
{
    public
    var item:(key:Mongo.Host, value:Mongo.ServerDescription<Mongo.Standalone, Owner>)?
    {
        self.value.map { (self.host, $0) }
    }
}
extension Mongo.Topology.Single
{
    public
    subscript(host:Mongo.Host) -> Mongo.ServerDescription<Mongo.Standalone, Owner>?
    {
        get
        {
            self.host == host ? self.value : nil
        }
        _modify
        {
            if  self.host == host
            {
                yield &self.value
            }
            else
            {
                var replacement:Mongo.ServerDescription<Mongo.Standalone, Owner>? = nil
                yield &replacement
                if let replacement:Mongo.ServerDescription<Mongo.Standalone, Owner>
                {
                    self.host = host
                    self.value = replacement
                }
            }
        }
    }
}
