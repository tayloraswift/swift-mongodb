import MongoChannel
import MongoConnection

extension MongoTopology
{
    @frozen public
    enum Servers:Sendable
    {
        /// No servers are reachable, desirable, or suitable. The
        /// ``case MongoTopology/.unknown(_:)`` topology always generates
        /// this value, but the ``case MongoTopology/.single(_:)`` topology
        /// can also generate if its sole server is unreachable.
        case none([Host: Unreachable])
        case single(Server<Standalone>)
        case sharded(Routers)
        case replicated(Members)
    }
}
extension MongoTopology.Servers
{
    @inlinable public static
    var none:Self
    {
        .none([:])
    }
}
extension MongoTopology.Servers
{
    @inlinable public
    var unreachable:[MongoTopology.Host: MongoTopology.Unreachable]
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
extension MongoTopology.Servers
{
    @inlinable public
    subscript(mode:MongoTopology.ReadMode,
        where eligibility:MongoTopology.Eligibility = .init()) -> MongoChannel?
    {
        switch self
        {
        case .none:
            return nil
        
        case .single(let standalone):
            switch mode
            {
            case .primary, .primaryPreferred, .nearest, .secondaryPreferred:
                return standalone.connection.channel
            case .secondary:
                return nil
            }
        
        case .sharded(let routers):
            return routers.candidates.first?.connection.channel
        
        case .replicated(let members):
            switch mode
            {
            case .primary:
                return members.primary
            case .primaryPreferred:
                return members.primary ?? members.secondary(by: eligibility)
            case .nearest:
                return members.nearest(by: eligibility)
            case .secondaryPreferred:
                return members.secondary(by: eligibility) ?? members.primary
            case .secondary:
                return members.secondary(by: eligibility)
            }
        }
    }
    @inlinable public
    func diagnose(mode:MongoTopology.ReadMode,
        where eligibility:MongoTopology.Eligibility = .init()) -> MongoTopology.Diagnostics
    {
        switch self
        {
        case .none(let unreachable):
            return .init(unreachable: unreachable)
        
        case .single(let standalone):
            switch mode
            {
            case .primary, .primaryPreferred, .nearest, .secondaryPreferred:
                return .init()
            case .secondary:
                return .init(undesirable: [standalone.host: .standalone])
            }
        
        case .sharded(let routers):
            return .init(unreachable: routers.unreachables)
        
        case .replicated(let members):
            let undesirable:[MongoTopology.Host: MongoTopology.Undesirable] =
                mode.diagnose(undesirable: members)
            
            let unsuitable:[MongoTopology.Host: MongoTopology.Unsuitable]
            switch mode
            {
            case .primary:
                unsuitable = [:]
            
            case .primaryPreferred, .secondaryPreferred, .secondary:
                unsuitable = eligibility.diagnose(unsuitable: members.candidates.secondaries)
            
            case .nearest:
                unsuitable = eligibility.diagnose(unsuitable: members.candidates.replicas)
            }

            return .init(unreachable: members.unreachables,
                undesirable: undesirable,
                unsuitable: unsuitable)
        }
    }
}
