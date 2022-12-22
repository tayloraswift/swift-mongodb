import MongoChannel

extension Mongo.Topology
{
    struct Single
    {
        private
        let host:Mongo.Host
        private
        var state:MongoChannel.State<Mongo.Single>

        private
        init(host:Mongo.Host, channel:MongoChannel, metadata:Mongo.Single)
        {
            self.host = host
            self.state = .connected(channel, metadata: metadata)
        }
    }
}
extension Mongo.Topology.Single
{
    func terminate()
    {
        self.state.channel?.heart.stop()
    }
    func errors() -> [Mongo.Host: any Error]
    {
        self.state.error.map { [self.host: $0] } ?? [:]
    }
}
extension Mongo.Topology.Single
{
    init?(host:Mongo.Host, channel:MongoChannel, metadata:Mongo.Single,
        seedlist:inout Mongo.Seedlist)
    {
        // https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#updateunknownwithstandalone
        if seedlist.pick(host: host)
        {
            self.init(host: host, channel: channel, metadata: metadata)
        }
        else
        {
            return nil
        }
    }
    mutating
    func clear(host:Mongo.Host, status:(any Error)?) -> Bool
    {
        self.host != host ? false :
        self.state.clear(status: status)
    }
    mutating
    func update(host:Mongo.Host, channel:MongoChannel, metadata:Mongo.Single) -> Bool
    {
        self.host != host ? false :
        self.state.update(channel: channel, metadata: metadata)
    }
}
extension Mongo.Topology.Single
{
    var master:MongoChannel?
    {
        self.state.channel
    }
}
