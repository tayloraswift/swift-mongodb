import Durations
import MongoClusters

extension Mongo.ServerTable
{
    struct Replicated:Sendable
    {
        let unreachables:[Mongo.Host: Mongo.Unreachable]
        let undesirables:[Mongo.Host: Mongo.Undesirable]

        private(set)
        var candidates:
        (
            secondaries:[Mongo.Server<Mongo.ReplicaQuality>],
            replicas:[Mongo.Server<Mongo.ReplicaQuality>],
            primary:Mongo.Server<Mongo.ReplicaQuality>?
        )

        let state:Mongo.DeploymentState

        private
        init(
            unreachables:[Mongo.Host: Mongo.Unreachable],
            undesirables:[Mongo.Host: Mongo.Undesirable],
            secondaries:[Mongo.Server<Mongo.ReplicaQuality>] = [],
            primary:Mongo.Server<Mongo.ReplicaQuality>? = nil,
            state:Mongo.DeploymentState)
        {
            self.unreachables = unreachables
            self.undesirables = undesirables

            self.candidates.secondaries = secondaries
            self.candidates.secondaries.sort
            {
                $0.metadata.latency < $1.metadata.latency
            }
            self.candidates.replicas = secondaries + (primary.map { [$0] } ?? [])
            self.candidates.replicas.sort
            {
                $0.metadata.latency < $1.metadata.latency
            }

            self.candidates.primary = primary
            self.state = state
        }
    }
}
extension Mongo.ServerTable.Replicated
{
    private
    init(heartbeatInterval:Milliseconds,
        unreachables:[Mongo.Host: Mongo.Unreachable],
        undesirables:[Mongo.Host: Mongo.Undesirable],
        secondaries:[Mongo.Server<Mongo.Replica>],
        primary:Mongo.Server<Mongo.Replica>?,
        state:Mongo.DeploymentState)
    {
        if  let primary:Mongo.Server<Mongo.Replica>
        {
            let freshest:Mongo.PrimaryBaseline = .init(primary.metadata.timings)

            self.init(
                unreachables: unreachables,
                undesirables: undesirables,
                secondaries: secondaries.map
                {
                    .secondary(from: $0,
                        heartbeatInterval: heartbeatInterval,
                        freshest: freshest)
                },
                primary: .primary(from: primary),
                state: state)
        }
        else if
            let secondary:Mongo.Server<Mongo.Replica> = secondaries.max(by:
            {
                $0.metadata.timings.write.value <
                $1.metadata.timings.write.value
            })
        {
            let freshest:Mongo.SecondaryBaseline = .init(secondary.metadata.timings)

            self.init(
                unreachables: unreachables,
                undesirables: undesirables,
                secondaries: secondaries.map
                {
                    .secondary(from: $0,
                        heartbeatInterval: heartbeatInterval,
                        freshest: freshest)
                },
                state: state)
        }
        else
        {
            assert(secondaries.isEmpty)

            self.init(
                unreachables: unreachables,
                undesirables: undesirables,
                state: state)
        }
    }
    init(from topology:borrowing Mongo.Topology<Mongo.TopologyModel.Canary>.Replicated,
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
            unreachables: unreachables,
            undesirables: undesirables,
            secondaries: secondaries,
            primary: primary,
            state: logicalSessionTimeoutMinutes == .max ? .unknown : .capable(.init(
                transactions: true,
                sessions: .init(rawValue: logicalSessionTimeoutMinutes))))
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
