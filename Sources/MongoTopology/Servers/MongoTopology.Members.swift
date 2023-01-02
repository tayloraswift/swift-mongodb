import Durations
import MongoChannel
import MongoConnection

extension MongoTopology
{
    public
    struct Members:Sendable
    {
        public
        let unreachables:[Host: Unreachable]
        let undesirables:[Host: Undesirable]

        @usableFromInline
        let candidates:
        (
            secondaries:[Server<Candidate>],
            replicas:[Server<Candidate>],
            primary:Server<Candidate>?
        )

        init(unreachables:[Host: Unreachable],
            undesirables:[Host: Undesirable],
            secondaries:[Server<Candidate>] = [],
            primary:Server<Candidate>? = nil)
        {
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
extension MongoTopology.Members
{
    init(heartbeatInterval:Milliseconds,
        unreachables:[MongoTopology.Host: MongoTopology.Unreachable],
        undesirables:[MongoTopology.Host: MongoTopology.Undesirable],
        secondaries:[MongoTopology.Server<MongoTopology.Replica>],
        primary:MongoTopology.Server<MongoTopology.Replica>?)
    {
        if  let primary:MongoTopology.Server<MongoTopology.Replica>
        {
            let freshest:MongoTopology.Timings.Primary = .init(
                primary.connection.metadata.timings)
            
            self.init(unreachables: unreachables, undesirables: undesirables,
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
        else if let secondary:MongoTopology.Server<MongoTopology.Replica> =
                    secondaries.max(by:
                    {
                        $0.connection.metadata.timings.write.value <
                        $1.connection.metadata.timings.write.value
                    })
        {
            let freshest:MongoTopology.Timings.Secondary = .init(
                secondary.connection.metadata.timings)

            self.init(unreachables: unreachables, undesirables: undesirables,
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
            
            self.init(unreachables: unreachables, undesirables: undesirables)
        }
    }
    init(heartbeatInterval:Milliseconds,
        members:[MongoTopology.Host: MongoConnection<MongoTopology.Member?>.State])
    {
        var unreachables:[MongoTopology.Host: MongoTopology.Unreachable] = [:],
            undesirables:[MongoTopology.Host: MongoTopology.Undesirable] = [:],
            secondaries:[MongoTopology.Server<MongoTopology.Replica>] = [],
            primary:MongoTopology.Server<MongoTopology.Replica>? = nil

        for (host, state):(MongoTopology.Host, MongoConnection<MongoTopology.Member?>.State)
            in members
        {
            let member:MongoConnection<MongoTopology.Member?>
            switch state
            {
            case .connected(let connection):
                member = connection
            
            case .errored(let error):
                unreachables[host] = .errored(error)
                continue
            
            case .queued:
                unreachables[host] = .queued
                continue
            }

            switch member.metadata
            {
            case .primary(let metadata)?:
                primary = .init(
                    connection: .init(metadata: metadata, channel: member.channel),
                    host: host)
            
            case .secondary(let metadata)?:
                secondaries.append(.init(
                    connection: .init(metadata: metadata, channel: member.channel),
                    host: host))
            
            case .arbiter?:
                undesirables[host] = .arbiter
            
            case .other?:
                undesirables[host] = .other
            
            case nil:
                undesirables[host] = .ghost
            }
        }

        self.init(heartbeatInterval: heartbeatInterval,
            unreachables: unreachables,
            undesirables: undesirables,
            secondaries: secondaries,
            primary: primary)
    }
}
extension MongoTopology.Members
{
    public
    var primary:MongoChannel?
    {
        self.candidates.primary?.connection.channel
    }
    public
    func nearest(
        by eligibility:MongoTopology.Eligibility) -> MongoChannel?
    {
        self.candidates.replicas.select(by: eligibility)
    }
    public
    func secondary(
        by eligibility:MongoTopology.Eligibility) -> MongoChannel?
    {
        self.candidates.secondaries.select(by: eligibility)
    }
}
