import MongoChannel
import MongoConnection

extension MongoTopology
{
    public
    struct Single
    {
        private
        let host:Host
        private
        var state:MongoConnection<Standalone>.State

        init(host:Host, channel:MongoChannel, metadata:Standalone)
        {
            self.host = host
            self.state = .connected(.init(metadata: metadata, channel: channel))
        }
    }
}
extension MongoTopology.Single
{
    func terminate()
    {
        self.state.connection?.channel.heart.stop()
    }
    // func errors() -> [MongoTopology.Host: any Error]
    // {
    //     self.state.error.map { [self.host: $0] } ?? [:]
    // }
}
extension MongoTopology.Single
{
    var servers:MongoTopology.Servers
    {
        switch self.state
        {
        case .connected(let connection):
            return .single(.init(connection: connection, host: self.host))
        
        case .errored(let error):
            return .none([.init(reason: .errored(error), host: self.host)])
        
        case .queued:
            return .none([.init(reason: .queued, host: self.host)])
        }
    }
}
extension MongoTopology.Single
{
    mutating
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
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
    func update(host:MongoTopology.Host, metadata:MongoTopology.Standalone,
        channel:MongoChannel) -> Bool
    {
        if self.host == host
        {
            self.state.update(with: .init(metadata: metadata, channel: channel))
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
