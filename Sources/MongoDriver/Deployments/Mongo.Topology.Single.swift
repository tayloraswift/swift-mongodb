extension Mongo.Topology
{
    struct Single
    {
        private
        let host:Mongo.Host
        private
        var state:Mongo.ConnectionState<Mongo.Single>

        private
        init(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Single)
        {
            self.host = host
            self.state = .connected(connection, metadata: metadata)
        }
    }
}
extension Mongo.Topology.Single
{
    init?(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Single,
        seedlist:inout Mongo.Seedlist)
    {
        // https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#updateunknownwithstandalone
        if seedlist.pick(host: host)
        {
            self.init(host: host, connection: connection, metadata: metadata)
        }
        else
        {
            return nil
        }
    }
    func end(sessions command:inout Mongo.EndSessions?)
    {
        self.state.end(sessions: &command)
    }
    mutating
    func clear(host:Mongo.Host, status:(any Error)?) -> Void?
    {
        self.host != host ? nil :
        self.state.clear(status: status)
    }
    mutating
    func update(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Single) -> Void?
    {
        self.host != host ? nil :
        self.state.update(connection: connection, metadata: metadata)
    }
}
extension Mongo.Topology.Single
{
    var master:Mongo.Connection?
    {
        self.state.connection
    }
}
