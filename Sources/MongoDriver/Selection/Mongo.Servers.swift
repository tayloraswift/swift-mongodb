import Durations

extension Mongo
{
    enum Servers:Sendable
    {
        /// No servers are reachable, desirable, or suitable. The
        /// ``case Mongo/Topology/.unknown(_:)`` topology always generates
        /// this value, but the ``case Mongo/Topology/.single(_:)`` topology
        /// can also generate if its sole server is unreachable.
        case none([Host: Unreachable])
        case single(Server<Standalone>)
        case sharded(Routers)
        case replicated(Members)
    }
}
extension Mongo.Servers
{
    static
    var none:Self
    {
        .none([:])
    }
}
extension Mongo.Servers
{
    init(from topology:__shared Mongo.Topology<Mongo.ConnectionPool>,
        heartbeatInterval:Milliseconds)
    {
        switch topology
        {
        case .terminated:
            self = .none
        
        case .unknown(let unknown):
            self = .none(unknown.ghosts)
        
        case .single(let single):
            switch single.state
            {
            case .monitoring(let metadata, let pool):
                self = .single(.init(metadata: metadata, pool: pool))
            
            case .errored(let error):
                self = .none([single.host: .errored(error)])
            
            case .queued:
                self = .none([single.host: .queued])
            }
        
        case .sharded(let sharded):
            self = .sharded(.init(from: sharded))
        
        case .replicated(let replicated):
            self = .replicated(.init(from: replicated, heartbeatInterval: heartbeatInterval))
        }
    }
}
extension Mongo.Servers
{
    var unreachable:[Mongo.Host: Mongo.Unreachable]
    {
        switch self
        {
        case .none(let unreachable):    return unreachable
        case .single(_):                return [:]
        case .sharded(let routers):     return routers.unreachables
        case .replicated(let members):  return members.unreachables
        }
    }
}
extension Mongo.Servers
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
                return standalone.pool
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
