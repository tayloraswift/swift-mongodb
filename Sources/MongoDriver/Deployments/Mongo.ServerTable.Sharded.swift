extension Mongo.ServerTable
{
    struct Sharded:Sendable
    {
        let unreachables:[Mongo.Host: Mongo.Unreachable]
        let candidates:[Mongo.Server<Mongo.Router>]

        let state:Mongo.DeploymentState

        private
        init(
            unreachables:[Mongo.Host: Mongo.Unreachable],
            candidates:[Mongo.Server<Mongo.Router>],
            state:Mongo.DeploymentState)
        {
            self.unreachables = unreachables
            self.candidates = candidates
            self.state = state
        }
    }
}
extension Mongo.ServerTable.Sharded
{
    init(from topology:__shared Mongo.Topology<Mongo.TopologyModel.Canary>.Sharded)
    {
        var logicalSessionTimeoutMinutes:UInt32 = .max

        var unreachables:[Mongo.Host: Mongo.Unreachable] = [:],
            candidates:[Mongo.Server<Mongo.Router>] = []

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
                candidates.append(.init(metadata: metadata, pool: owner.pool))

                logicalSessionTimeoutMinutes = min(logicalSessionTimeoutMinutes,
                    metadata.capabilities.logicalSessionTimeoutMinutes)

            case .errored(let error):
                unreachables[host] = .errored(error)

            case .queued:
                unreachables[host] = .queued
            }
        }

        self.init(
            unreachables: unreachables,
            candidates: candidates,
            state: logicalSessionTimeoutMinutes == .max ? .unknown : .capable(.init(
                transactions: true,
                sessions: .init(rawValue: logicalSessionTimeoutMinutes))))
    }
}
