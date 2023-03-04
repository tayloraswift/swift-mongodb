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
        case .none(let unreachable):        return unreachable
        case .single(_):                    return [:]
        case .sharded(let sharded):         return sharded.unreachables
        case .replicated(let replicated):   return replicated.unreachables
        }
    }
    var capabilities:Mongo.DeploymentCapabilities?
    {
        switch self
        {
        case .none:                         return nil
        case .single(let single):           return single.capabilities
        case .sharded(let sharded):         return sharded.capabilities
        case .replicated(let replicated):   return replicated.capabilities
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
            return nil
        
        case .single(let standalone):
            switch preference
            {
            case .primary, .primaryPreferred, .nearest, .secondaryPreferred:
                return standalone.server.pool
            case .secondary:
                return nil
            }
        
        case .sharded(let routers):
            return routers.candidates.first?.pool
        
        case .replicated(let members):
            switch preference
            {
            case .primary:
                return members.primary
            
            case .primaryPreferred      (let eligibility, hedge: _):
                return members.primary ?? members.secondary(by: eligibility)
            
            case .nearest               (let eligibility, hedge: _):
                return members.nearest(by: eligibility)
            
            case .secondaryPreferred    (let eligibility, hedge: _):
                return members.secondary(by: eligibility) ?? members.primary
            
            case .secondary             (let eligibility, hedge: _):
                return members.secondary(by: eligibility)
            }
        }
    }
}
