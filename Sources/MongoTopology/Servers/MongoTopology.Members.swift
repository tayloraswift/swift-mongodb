import Durations
import MongoChannel
import MongoConnection

extension MongoTopology
{
    public
    struct Members:Sendable
    {
        public
        let unreachables:[Rejection<Unreachable>]
        let undesirables:[Rejection<Undesirable>]
        let candidates:
        (
            secondaries:[Server<Candidate>],
            replicas:[Server<Candidate>],
            primary:Server<Candidate>?
        )

        init(unreachables:[Rejection<Unreachable>],
            undesirables:[Rejection<Undesirable>],
            candidates:
            (
                primary:Server<Candidate>?,
                secondaries:[Server<Candidate>]
            ))
        {
            self.unreachables = unreachables
            self.undesirables = undesirables
            // TODO: sort this by latency
            self.candidates.secondaries = candidates.secondaries
            // TODO: sort this by latency
            self.candidates.replicas = candidates.secondaries +
                (candidates.primary.map { [$0] } ?? [])
            self.candidates.primary = candidates.primary
        }
    }
}
extension MongoTopology.Members
{
    init(unreachables:[MongoTopology.Rejection<MongoTopology.Unreachable>],
        undesirables:[MongoTopology.Rejection<MongoTopology.Undesirable>],
        secondaries:[MongoTopology.Server<MongoTopology.Replica>],
        primary:MongoTopology.Server<MongoTopology.Replica>?)
    {
        let candidates:
        (
            primary:MongoTopology.Server<MongoTopology.Candidate>?,
            secondaries:[MongoTopology.Server<MongoTopology.Candidate>]
        )

        let freshest:Freshest
        if  let primary:MongoTopology.Server<MongoTopology.Replica>
        {
            freshest = .primary(primary.connection.metadata.timings)
            //  the primary always has a staleness of zero, even though the formula
            //  would suggest it have a staleness of `heartbeatFrequency`:
            //  '''
            //  Non-secondary servers (including Mongos servers) have zero staleness.
            //  '''
            candidates.primary = primary.map
            {
                .init(staleness: .zero, tags: $0.tags)
            }
        }
        else if let secondary:MongoTopology.Server<MongoTopology.Replica> =
                    secondaries.max(by:
                    {
                        $0.connection.metadata.timings.write.value <
                        $1.connection.metadata.timings.write.value
                    })
        {
            candidates.primary = nil
            freshest = .secondary(secondary.connection.metadata.timings.write)

        }
        else
        {
            assert(secondaries.isEmpty)
            
            self.init(unreachables: unreachables,
                undesirables: undesirables,
                candidates: (nil, []))
            return
        }
        
        candidates.secondaries = secondaries.map
        {
            $0.map
            {
                .init(staleness: $0.staleness(freshest: freshest), tags: $0.tags)
            }
        }

        self.init(unreachables: unreachables,
            undesirables: undesirables,
            candidates: candidates)
    }
    init(members:[MongoTopology.Host: MongoConnection<MongoTopology.Member?>.State])
    {
        var unreachables:[MongoTopology.Rejection<MongoTopology.Unreachable>] = [],
            undesirables:[MongoTopology.Rejection<MongoTopology.Undesirable>] = [],
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
                unreachables.append(.init(reason: .errored(error), host: host))
                continue
            
            case .queued:
                unreachables.append(.init(reason: .queued, host: host))
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
                undesirables.append(.init(reason: .arbiter, host: host))
            
            case .other?:
                undesirables.append(.init(reason: .other, host: host))
            
            case nil:
                undesirables.append(.init(reason: .ghost, host: host))
            }
        }

        self.init(unreachables: unreachables,
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
