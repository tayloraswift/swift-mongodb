import Durations

extension Mongo
{
    enum ServerTable:Sendable
    {
        /// No servers are reachable, desirable, or suitable. The
        /// ``case Mongo/Topology/.unknown(_:)`` topology always generates
        /// this value, but the ``case Mongo/Topology/.single(_:)`` topology
        /// can also generate if its sole server is unreachable.
        case none([Host: Unreachable])
        case single(Single)
        case sharded(Sharded)
        case replicated(Replicated)
    }
}
extension Mongo.ServerTable
{
    static
    var none:Self
    {
        .none([:])
    }
}
extension Mongo.ServerTable
{
    var unreachable:[Mongo.Host: Mongo.Unreachable]
    {
        switch self
        {
        case .none(let unreachable):        unreachable
        case .single(_):                    [:]
        case .sharded(let sharded):         sharded.unreachables
        case .replicated(let replicated):   replicated.unreachables
        }
    }
    var capabilities:Mongo.DeploymentCapabilities?
    {
        switch self
        {
        case .none:                         nil
        case .single(let single):           single.capabilities
        case .sharded(let sharded):         sharded.capabilities
        case .replicated(let replicated):   replicated.capabilities
        }
    }
}
extension Mongo.ServerTable
{
    init(from topology:__shared Mongo.Topology<Mongo.TopologyModel.Canary>,
        heartbeatInterval:Milliseconds)
    {
        switch topology
        {
        case .unknown(let unknown):
            self = .none(unknown.ghosts)
        
        case .single(let single):
            switch single.item
            {
            case (_, .connected(let metadata, let owner))?:
                self = .single(.init(capabilities: .init(
                        transactions: nil,
                        sessions: .init(
                            rawValue: metadata.capabilities.logicalSessionTimeoutMinutes)),
                    server: .init(metadata: metadata, pool: owner.pool)))
            
            case (let host, .errored(let error))?:
                self = .none([host: .errored(error)])
            
            case (let host, .queued)?:
                self = .none([host: .queued])
            
            case nil:
                self = .none
            }
        
        case .sharded(let sharded):
            self = .sharded(.init(from: sharded))
        
        case .replicated(let replicated):
            self = .replicated(.init(from: replicated, heartbeatInterval: heartbeatInterval))
        }
    }
}
extension Mongo.ServerTable
{
    subscript(preference:Mongo.ReadPreference) -> Mongo.ConnectionPool?
    {
        switch self
        {
        case .none:
            nil
        
        case .single(let standalone):
            switch preference
            {
            case .primary, .primaryPreferred, .nearest, .secondaryPreferred:
                standalone.server.pool
            case .secondary:
                nil
            }
        
        case .sharded(let routers):
            routers.candidates.first?.pool
        
        case .replicated(let members):
            switch preference
            {
            case .primary:
                members.primary
            
            case .primaryPreferred      (let eligibility, hedge: _):
                members.primary ?? members.secondary(by: eligibility)
            
            case .nearest               (let eligibility, hedge: _):
                members.nearest(by: eligibility)
            
            case .secondaryPreferred    (let eligibility, hedge: _):
                members.secondary(by: eligibility) ?? members.primary
            
            case .secondary             (let eligibility, hedge: _):
                members.secondary(by: eligibility)
            }
        }
    }
}
