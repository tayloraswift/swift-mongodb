
extension Mongo
{
    enum Topology
    {
        case terminated

        case unknown(Seedlist)
        case single(Single)
        case sharded(Sharded)
        case replicated(Replicated)
    }
}
extension Mongo.Topology
{
    mutating
    func terminate()
    {
        defer
        {
            self = .terminated
        }
        switch self
        {
        case .terminated, .unknown(_):  break
        case .single(let topology):     topology.terminate()
        case .sharded(let topology):    topology.terminate()
        case .replicated(let topology): topology.terminate()
        }
    }
}
extension Mongo.Topology
{
    private
    init?(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Server,
        seedlist:inout Mongo.Seedlist,
        monitor:(Mongo.Host) -> ())
    {
        switch metadata
        {
        case    .single(let metadata):
            if  let topology:Mongo.Topology.Single = .init(host: host,
                    connection: connection,
                    metadata: metadata,
                    seedlist: &seedlist)
            {
                self = .single(topology)
            }
            else
            {
                return nil
            }
        
        case    .router(let metadata):
            if  let sharded:Mongo.Topology.Sharded = .init(host: host,
                    connection: connection,
                    metadata: metadata,
                    seedlist: &seedlist)
            {
                self = .sharded(sharded)
            }
            else
            {
                return nil
            }
        
        case    .replica(let metadata, let peerlist):
            if  let replicated:Mongo.Topology.Replicated = .init(host: host,
                    connection: connection,
                    metadata: metadata,
                    seedlist: &seedlist,
                    peerlist: peerlist,
                    monitor: monitor)
            {
                self = .replicated(replicated)
            }
            else
            {
                return nil
            }
        
        case    .replicaGhost:
            //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#topologytype-remains-unknown-when-an-rsghost-is-discovered
            self = .unknown(seedlist)
        }
    }
    mutating
    func clear(host:Mongo.Host, status:(any Error)?) -> Void?
    {
        switch self
        {
        case .terminated:
            return nil
        
        case .unknown(var seedlist):
            self = .unknown(.init())
            defer
            {
                self = .unknown(seedlist)
            }
            return seedlist.clear(host: host, status: status)
        
        case .single(var topology):
            self = .unknown(.init())
            defer
            {
                self = .single(topology)
            }
            return topology.clear(host: host, status: status)
        
        case .sharded(var topology):
            self = .unknown(.init())
            defer
            {
                self = .sharded(topology)
            }
            return topology.clear(host: host, status: status)
        
        case .replicated(var topology):
            self = .unknown(.init())
            defer
            {
                self = .replicated(topology)
            }
            return topology.clear(host: host, status: status)
        }
    }
    mutating
    func update(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Server,
        monitor:(Mongo.Host) -> ()) -> Void?
    {
        switch self
        {
        case .terminated:
            return nil
        
        case .unknown(var seeds):
            if  let topology:Self = .init(host: host, connection: connection,
                    metadata: metadata,
                    seedlist: &seeds,
                    monitor: monitor)
            {
                self = topology
                return ()
            }
            else
            {
                self = .unknown(seeds)
                return nil
            }
        
        case .single(var topology):
            self = .unknown(.init())
            defer
            {
                self = .single(topology)
            }
            if case .single(let metadata) = metadata
            {
                return topology.update(host: host, connection: connection, metadata: metadata)
            }
            else
            {
                // we cannot remove and stop monitoring the only host we know about
                return topology.clear(host: host, status: nil)
            }
        
        case .sharded(var topology):
            self = .unknown(.init())
            defer
            {
                self = .sharded(topology)
            }
            if case .router(let metadata) = metadata
            {
                return topology.update(host: host, connection: connection, metadata: metadata)
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
            switch metadata
            {
            case    .replica(let metadata, let peerlist):
                return topology.update(host: host, connection: connection, metadata: metadata,
                    peerlist: peerlist,
                    monitor: monitor)
            
            case    .replicaGhost:
                //  this is not the same as clearing the descriptor
                return topology.update(host: host, connection: connection, metadata: ())
            
            default:
                // remove and stop monitoring
                return topology.remove(host: host)
            }
        }
    }
}

extension Mongo.Topology
{
    /// Returns a connection to a master server, if one is available, and
    /// according to the current topology type.
    ///
    /// For ``case single(_:)`` topologies, this will return a connection
    /// to the lone server, if available.
    ///
    /// For ``case sharded(_:)`` topologies, this will return any available
    /// router.
    ///
    /// For ``case replicated(_:)`` topologies, this will return a connection
    /// to the primary replica, if available.
    ///
    /// For ``case unknown(_:)`` topologies, this will always return [`nil`]().
    var master:Mongo.Connection?
    {
        switch self
        {
        case .terminated, .unknown(_):  return nil
        case .single(let topology):     return topology.master
        case .sharded(let topology):    return topology.any
        case .replicated(let topology): return topology.master
        }
    }
    /// Returns a connection to any data-bearing server, if one is available,
    /// and according to the current topology type.
    ///
    /// For ``case single(_:)`` topologies, this will return a connection
    /// to the lone server, if available.
    ///
    /// For ``case sharded(_:)`` topologies, this will return any available
    /// router.
    ///
    /// For ``case replicated(_:)`` topologies, this will return a connection
    /// to any available primary or secondary replica.
    ///
    /// For ``case unknown(_:)`` topologies, this will always return [`nil`]().
    var any:Mongo.Connection?
    {
        switch self
        {
        case .terminated, .unknown(_):  return nil
        case .single(let topology):     return topology.master
        case .sharded(let topology):    return topology.any
        case .replicated(let topology): return topology.any
        }
    }

    subscript(selector:Mongo.ServerSelector) -> Mongo.Connection?
    {
        switch selector
        {
        case .master:   return self.master
        case .any:      return self.any
        }
    }
}
