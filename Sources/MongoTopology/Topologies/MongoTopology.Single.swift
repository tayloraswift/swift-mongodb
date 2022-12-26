import MongoChannel

extension MongoTopology
{
    public
    struct Single
    {
        private
        let host:Host
        private
        var state:MongoChannel.State<Standalone>

        private
        init(host:Host, channel:MongoChannel, metadata:Standalone)
        {
            self.host = host
            self.state = .connected(channel, metadata: metadata)
        }
    }
}
extension MongoTopology.Single
{
    func terminate()
    {
        self.state.channel?.heart.stop()
    }
    func errors() -> [MongoTopology.Host: any Error]
    {
        self.state.error.map { [self.host: $0] } ?? [:]
    }
}
extension MongoTopology.Single
{
    init?(host:MongoTopology.Host, channel:MongoChannel,
        metadata:MongoTopology.Standalone,
        seedlist:inout MongoTopology.Unknown)
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
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
    {
        self.host != host ? false :
        self.state.clear(status: status)
    }
    mutating
    func update(host:MongoTopology.Host, channel:MongoChannel,
        metadata:MongoTopology.Standalone) -> Bool
    {
        self.host != host ? false :
        self.state.update(channel: channel, metadata: metadata)
    }
}
extension MongoTopology.Single
{
    public
    var master:MongoChannel?
    {
        self.state.channel
    }
}
