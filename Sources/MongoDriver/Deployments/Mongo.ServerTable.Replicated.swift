import Durations

extension Mongo.ServerTable
{
    struct Replicated:Sendable
    {
        let capabilities:Mongo.DeploymentCapabilities?

        let unreachables:[Mongo.Host: Mongo.Unreachable]
        let undesirables:[Mongo.Host: Mongo.Undesirable]

        let candidates:
        (
            secondaries:[Mongo.Server<ReplicaQuality>],
            replicas:[Mongo.Server<ReplicaQuality>],
            primary:Mongo.Server<ReplicaQuality>?
        )

        private
        init(capabilities:Mongo.DeploymentCapabilities?,
            unreachables:[Mongo.Host: Mongo.Unreachable],
            undesirables:[Mongo.Host: Mongo.Undesirable],
            secondaries:[Mongo.Server<ReplicaQuality>] = [],
            primary:Mongo.Server<ReplicaQuality>? = nil)
        {
            self.capabilities = capabilities
            self.unreachables = unreachables
            self.undesirables = undesirables
            // TODO: sort this by latency
            self.candidates.secondaries = secondaries
            // TODO: sort this by latency
            self.candidates.replicas = secondaries + (primary.map { [$0] } ?? [])
            self.candidates.primary = primary
        }
    }
}
extension Mongo.ServerTable.Replicated
{
    private
    init(heartbeatInterval:Milliseconds,
        capabilities:Mongo.DeploymentCapabilities?,
        unreachables:[Mongo.Host: Mongo.Unreachable],
        undesirables:[Mongo.Host: Mongo.Undesirable],
        secondaries:[Mongo.Server<Mongo.Replica>],
        primary:Mongo.Server<Mongo.Replica>?)
    {
        if  let primary:Mongo.Server<Mongo.Replica>
        {
            let freshest:Mongo.Replica.PrimaryBaseline = .init(primary.metadata.timings)
            
            self.init(capabilities: capabilities,
                unreachables: unreachables,
                undesirables: undesirables,
                secondaries: secondaries.map
                {
                    $0.map
                    {
                        .init(staleness: freshest - $0.timings + heartbeatInterval,
                            tags: $0.tags)
                    }
                },
                primary: primary.map
                {
                    //  the primary always has a staleness of zero, even though the
                    //  formula would suggest it have a staleness of `heartbeatFrequency`:
                    //  '''
                    //  Non-secondary servers (including Mongos servers) have zero
                    /// staleness.
                    //  '''
                    .init(staleness: .zero, tags: $0.tags)
                })
        }
        else if let secondary:Mongo.Server<Mongo.Replica> =
                    secondaries.max(by:
                    {
                        $0.metadata.timings.write.value <
                        $1.metadata.timings.write.value
                    })
        {
            let freshest:Mongo.Replica.SecondaryBaseline = .init(secondary.metadata.timings)

            self.init(capabilities: capabilities,
                unreachables: unreachables,
                undesirables: undesirables,
                secondaries: secondaries.map
                {
                    $0.map
                    {
                        .init(staleness: freshest - $0.timings + heartbeatInterval,
                            tags: $0.tags)
                    }
                })
        }
        else
        {
            assert(secondaries.isEmpty)
            
            self.init(capabilities: capabilities,
                unreachables: unreachables,
                undesirables: undesirables)
        }
    }
    init(from topology:__shared Mongo.Topology<Mongo.TopologyModel.Canary>.Replicated,
        heartbeatInterval:Milliseconds)
    {
        var logicalSessionTimeoutMinutes:UInt32 = .max

        var unreachables:[Mongo.Host: Mongo.Unreachable] = [:],
            undesirables:[Mongo.Host: Mongo.Undesirable] = [:],
            secondaries:[Mongo.Server<Mongo.Replica>] = [],
            primary:Mongo.Server<Mongo.Replica>? = nil

        for (host, state):
        (
            Mongo.Host, 
            Mongo.ServerDescription<Mongo.ReplicaSetMember, Mongo.TopologyModel.Canary>
        )
            in topology
        {
            let member:Mongo.ReplicaSetMember
            let pool:Mongo.ConnectionPool
            switch state
            {
            case .connected(let metadata, let owner):
                member = metadata
                pool = owner.pool
            
            case .errored(let error):
                unreachables[host] = .errored(error)
                continue
            
            case .queued:
                unreachables[host] = .queued
                continue
            }

            switch member
            {
            case .primary(let metadata):
                primary = .init(metadata: metadata, pool: pool)
                
                logicalSessionTimeoutMinutes = min(logicalSessionTimeoutMinutes,
                    metadata.capabilities.logicalSessionTimeoutMinutes)
            
            case .secondary(let metadata):
                secondaries.append(.init(metadata: metadata, pool: pool))
                
                logicalSessionTimeoutMinutes = min(logicalSessionTimeoutMinutes,
                    metadata.capabilities.logicalSessionTimeoutMinutes)
            
            case .arbiter:
                undesirables[host] = .arbiter
            
            case .other:
                undesirables[host] = .other
            
            case .ghost:
                undesirables[host] = .ghost
            }
        }

        self.init(heartbeatInterval: heartbeatInterval,
            capabilities: logicalSessionTimeoutMinutes == .max ? nil : .init(
                transactions: .supported,
                sessions: .init(rawValue: logicalSessionTimeoutMinutes)),
            unreachables: unreachables,
            undesirables: undesirables,
            secondaries: secondaries,
            primary: primary)
    }
}
extension Mongo.ServerTable.Replicated
{
    var primary:Mongo.ConnectionPool?
    {
        self.candidates.primary?.pool
    }
    func nearest(
        by eligibility:Mongo.ReadPreference.Eligibility) -> Mongo.ConnectionPool?
    {
        self.candidates.replicas.select(by: eligibility)
    }
    func secondary(
        by eligibility:Mongo.ReadPreference.Eligibility) -> Mongo.ConnectionPool?
    {
        self.candidates.secondaries.select(by: eligibility)
    }
}
