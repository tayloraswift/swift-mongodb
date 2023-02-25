import MongoMonitoring

extension Mongo
{
    @frozen public
    enum Topology<Owner> where Owner:AnyObject
    {
        case unknown(Unknown)
        case single(Single)
        case sharded(Sharded)
        case replicated(Replicated)
    }
}
extension Mongo.Topology:Sendable where Owner:Sendable
{
}
extension Mongo.Topology
{
    /// Places this topology in a ``case terminated`` state and sends shutdown
    /// signals to all currently-active heartbeats registered with it.
    @available(*, deprecated)
    public mutating
    func removeAll()
    {
        self = .unknown(.init())
        // defer
        // {
        //     self = .unknown(.init())
        // }
        // switch self
        // {
        // case .unknown(_):
        //     break
        
        // case .single:
        //     //topology.state.pool?.stopMonitoring()
        //     break
        
        // case .sharded:
        //     for router:Mongo.ServerDescription<Mongo.Router, Pool>
        //         in topology.routers.values
        //     {
        //         router.pool?.stopMonitoring()
        //     }
        
        // case .replicated(let topology):
        //     for member:Mongo.ServerDescription<Mongo.ReplicaSetMember, Pool>
        //         in topology.members.values
        //     {
        //         member.pool?.stopMonitoring()
        //     }
        // }
    }
}
extension Mongo.Topology
{
    private
    init?(host:Mongo.Host, with update:Mongo.TopologyUpdate, owner:Owner,
        from unknown:inout Unknown,
        add:(Mongo.Host) -> ())
    {
        switch update
        {
        case .standalone(let metadata):
            //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#updateunknownwithstandalone
            if  unknown.pick(host: host)
            {
                self = .single(.init(host: host, metadata: metadata, owner: owner))
                return
            }
            else
            {
                return nil
            }
        
        case .router(let metadata):
            var sharded:Sharded = .init(from: unknown)
            if case .accepted? = sharded[host]?.assign(metadata: metadata, owner: owner)
            {
                self = .sharded(sharded)
                return
            }
        
        case .primary(let primary, let peerlist):
            var replicated:Replicated = .init(from: unknown, name: peerlist.set)
            if  let metadata:Mongo.ReplicaSetMember = replicated.combine(update: primary,
                        peerlist: peerlist,
                        host: host,
                        add: add),
                case .accepted? = replicated[host]?.assign(metadata: metadata, owner: owner)
            {
                self = .replicated(replicated)
                return
            }
        
        case .slave(let slave, let peerlist):
            var replicated:Replicated = .init(from: unknown, name: peerlist.set)
            if  let metadata:Mongo.ReplicaSetMember = replicated.combine(update: slave, 
                    peerlist: peerlist,
                    host: host,
                    add: add),
                case .accepted? = replicated[host]?.assign(metadata: metadata, owner: owner)
            {
                self = .replicated(replicated)
                return
            }
        
        case .ghost:
            //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#topologytype-remains-unknown-when-an-rsghost-is-discovered
            self = .unknown(unknown)
            return
        }

        unknown.pick(host: host)
        return nil
    }

    public mutating
    func combine(update:Mongo.TopologyUpdate,
        owner:__owned Owner?,
        host:Mongo.Host,
        add:(Mongo.Host) -> ()) -> Mongo.TopologyUpdateResult
    {
        switch self
        {
        case .unknown(var unknown):
            guard let owner:Owner
            else
            {
                return .dropped
            }
            if  let topology:Self = .init(host: host, with: update, owner: owner,
                    from: &unknown,
                    add: add)
            {
                self = topology
                return .accepted
            }
            else
            {
                self = .unknown(unknown)
                return .rejected
            }
        
        case .single(var topology):
            self = .unknown(.init())
            defer
            {
                self = .single(topology)
            }
            switch update
            {
            case .standalone(let metadata):
                return topology[host]?.assign(metadata: metadata, owner: owner) ?? .rejected
            
            case .primary, .slave, .ghost, .router:
                // we cannot remove and stop monitoring the only host we know about
                return topology[host]?.assign(error: nil) ?? .rejected
            }
        
        case .sharded(var topology):
            self = .unknown(.init())
            defer
            {
                self = .sharded(topology)
            }
            switch update
            {
            case .router(let metadata):
                return topology[host]?.assign(metadata: metadata, owner: owner) ?? .rejected
            
            case .primary, .slave, .ghost, .standalone:
                topology[host] = nil
                return .rejected
            }
        
        case .replicated(var topology):
            self = .unknown(.init())
            defer
            {
                self = .replicated(topology)
            }

            let metadata:Mongo.ReplicaSetMember?

            switch update
            {
            case .primary(let primary, let peerlist):
                metadata = topology.combine(update: primary, peerlist: peerlist,
                    host: host,
                    add: add)
            
            case .slave(let slave, let peerlist):
                metadata = topology.combine(update: slave, peerlist: peerlist,
                    host: host,
                    add: add)
            
            case .ghost:
                metadata = .ghost
            
            case .router, .standalone:
                topology[host] = nil
                return .rejected
            }

            guard let metadata:Mongo.ReplicaSetMember
            else
            {
                return .rejected
            }

            return topology[host]?.assign(metadata: metadata, owner: owner) ?? .rejected
        }
    }
    public mutating
    func combine(error status:(any Error)?, host:Mongo.Host) -> Mongo.TopologyUpdateResult
    {
        switch self
        {
        case .unknown(var seedlist):
            self = .unknown(.init())
            defer
            {
                self = .unknown(seedlist)
            }
            return seedlist.combine(error: status, host: host)
        
        case .single(var topology):
            self = .unknown(.init())
            defer
            {
                self = .single(topology)
            }
            return topology[host]?.assign(error: status) ?? .rejected
        
        case .sharded(var topology):
            self = .unknown(.init())
            defer
            {
                self = .sharded(topology)
            }
            return topology[host]?.assign(error: status) ?? .rejected
        
        case .replicated(var topology):
            self = .unknown(.init())
            defer
            {
                self = .replicated(topology)
            }
            return topology[host]?.assign(error: status) ?? .rejected
        }
    }
}
