extension Mongo.Servers
{
    public
    struct Routers:Sendable
    {
        public private(set)
        var unreachables:[Mongo.Host: Mongo.Unreachable]
        public private(set)
        var candidates:[Mongo.Server<Mongo.Router>]

        private
        init(unreachables:[Mongo.Host: Mongo.Unreachable] = [:],
            candidates:[Mongo.Server<Mongo.Router>] = [])
        {
            self.unreachables = unreachables
            self.candidates = candidates
        }
    }
}
extension Mongo.Servers.Routers
{
    init(from topology:__shared Mongo.Topology<Mongo.TopologyModel.Canary>.Sharded)
    {
        self.init()
        for (host, state):
        (
            Mongo.Host, 
            Mongo.ServerDescription<Mongo.Router, Mongo.TopologyModel.Canary>
        )
            in topology
        {
            switch state
            {
            case .connected(let metadata, let owner):
                self.candidates.append(.init(metadata: metadata, pool: owner.pool))
            
            case .errored(let error):
                self.unreachables[host] = .errored(error)
            
            case .queued:
                self.unreachables[host] = .queued
            }
        }
    }
}
