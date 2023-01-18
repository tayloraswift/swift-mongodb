import MongoMonitoring

extension Mongo
{
    @frozen public
    enum Topology<Pool>:Sendable where Pool:AnyObject & Sendable & MongoMonitoringDelegate
    {
        case unknown(Unknown)
        case single(Single)
        case sharded(Sharded)
        case replicated(Replicated)
    }
}
extension Mongo.Topology
{
    /// Places this topology in a ``case terminated`` state and sends shutdown
    /// signals to all currently-active heartbeats registered with it.
    public mutating
    func removeAll()
    {
        defer
        {
            self = .unknown(.init())
        }
        switch self
        {
        case .unknown(_):
            break
        
        case .single(let topology):
            topology.state.pool?.stopMonitoring()
        
        case .sharded(let topology):
            for router:Mongo.ServerDescription<Mongo.Router, Pool>
                in topology.routers.values
            {
                router.pool?.stopMonitoring()
            }
        
        case .replicated(let topology):
            for member:Mongo.ServerDescription<Mongo.ReplicaSetMember?, Pool>
                in topology.members.values
            {
                member.pool?.stopMonitoring()
            }
        }
    }
}
extension Mongo.Topology
{
    private
    init?(host:Mongo.Host, with update:Mongo.TopologyUpdate?, pool:Pool,
        from unknown:inout Unknown,
        add:(Mongo.Host) -> ())
    {
        switch update
        {
        case .standalone(let metadata)?:
            //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#updateunknownwithstandalone
            if  unknown.pick(host: host)
            {
                self = .single(.init(host: host, metadata: metadata, pool: pool))
            }
            else
            {
                return nil
            }
        
        case .router(let metadata)?:
            var sharded:Sharded = .init(from: unknown)
            if  sharded.combine(metadata: metadata, host: host, pool: pool)
            {
                self = .sharded(sharded)
            }
            else
            {
                unknown.pick(host: host)
                return nil
            }
        
        case .master(let master, let peerlist)?:
            var replicated:Replicated = .init(from: unknown, name: peerlist.set)
            if  replicated.combine(update: master, peerlist: peerlist,
                    host: host,
                    pool: pool,
                    add: add)
            {
                self = .replicated(replicated)
            }
            else
            {
                unknown.pick(host: host)
                return nil
            }
        
        case .slave(let slave, let peerlist)?:
            var replicated:Replicated = .init(from: unknown, name: peerlist.set)
            if  replicated.combine(update: slave, peerlist: peerlist,
                    host: host,
                    pool: pool,
                    add: add)
            {
                self = .replicated(replicated)
            }
            else
            {
                unknown.pick(host: host)
                return nil
            }
        
        case nil:
            //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#topologytype-remains-unknown-when-an-rsghost-is-discovered
            self = .unknown(unknown)
        }
    }
    public mutating
    func combine(error status:(any Error)?, host:Mongo.Host) -> Bool
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
            return topology.combine(error: status, host: host)
        
        case .sharded(var topology):
            self = .unknown(.init())
            defer
            {
                self = .sharded(topology)
            }
            return topology.combine(error: status, host: host)
        
        case .replicated(var topology):
            self = .unknown(.init())
            defer
            {
                self = .replicated(topology)
            }
            return topology.combine(error: status, host: host)
        }
    }
    public mutating
    func combine(update:Mongo.TopologyUpdate?, host:Mongo.Host, pool:Pool,
        add:(Mongo.Host) -> ()) -> Bool
    {
        switch self
        {
        case .unknown(var unknown):
            if  let topology:Self = .init(host: host, with: update, pool: pool,
                    from: &unknown,
                    add: add)
            {
                self = topology
                return true
            }
            else
            {
                self = .unknown(unknown)
                return false
            }
        
        case .single(var topology):
            self = .unknown(.init())
            defer
            {
                self = .single(topology)
            }
            if case .standalone(let metadata)? = update
            {
                return topology.combine(metadata: metadata, host: host, pool: pool)
            }
            else
            {
                // we cannot remove and stop monitoring the only host we know about
                return topology.combine(error: nil, host: host)
            }
        
        case .sharded(var topology):
            self = .unknown(.init())
            defer
            {
                self = .sharded(topology)
            }
            if case .router(let metadata)? = update
            {
                return topology.combine(metadata: metadata, host: host, pool: pool)
            }
            else
            {
                // remove and stop monitoring
                return topology.remove(host: host)
            }
        
        case .replicated(var topology):
            self = .unknown(.init())
            defer
            {
                self = .replicated(topology)
            }
            switch update
            {
            case .master(let master, let peerlist)?:
                return topology.combine(update: master, peerlist: peerlist,
                    host: host,
                    pool: pool,
                    add: add)
            
            case .slave(let slave, let peerlist)?:
                return topology.combine(update: slave, peerlist: peerlist,
                    host: host,
                    pool: pool,
                    add: add)
            
            case nil:
                //  this is not the same as clearing the descriptor
                return topology.combine(metadata: (),
                    host: host,
                    pool: pool)
            
            default:
                // remove and stop monitoring
                return topology.remove(host: host)
            }
        }
    }
}
