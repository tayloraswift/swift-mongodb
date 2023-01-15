import MongoMonitoringDelegate

extension Mongo.Topology
{
    public
    struct Single
    {
        public
        let host:Mongo.Host
        public private(set)
        var state:Mongo.ServerDescription<Mongo.Standalone, Pool>

        init(host:Mongo.Host, metadata:Mongo.Standalone, pool:Pool)
        {
            self.host = host
            self.state = .monitoring(metadata, pool)
        }
    }
}
extension Mongo.Topology.Single
{
    mutating
    func combine(error status:(any Error)?, host:Mongo.Host) -> Bool
    {
        if self.host == host
        {
            self.state.clear(status: status)
            return true
        }
        else
        {
            return false
        }
    }
    mutating
    func combine(metadata:Mongo.Standalone, host:Mongo.Host, pool:Pool) -> Bool
    {
        if self.host == host
        {
            self.state.update(with: metadata, pool: pool)
            return true
        }
        else
        {
            return false
        }
    }
}
// extension MongoTopology.Single
// {
//     public
//     var channel:MongoChannel?
//     {
//         self.state.channel
//     }
// }
