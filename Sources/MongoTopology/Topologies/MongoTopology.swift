import MongoChannel

@frozen public
enum MongoTopology
{
    case terminated

    case unknown(Unknown)
    case single(Single)
    case sharded(Sharded)
    case replicated(Replicated)
}
extension MongoTopology
{
    /// Places this topology in a ``case terminated`` state and sends shutdown
    /// signals to all currently-active heartbeats registered with it.
    public mutating
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
    /// Returns the most recent error tracked by the topology for each
    /// currently-errored channel.
    public
    func errors() -> [MongoTopology.Host: any Error]
    {
        switch self
        {
        case .terminated:               return [:]
        case .unknown(let topology):    return topology.errors()
        case .single(let topology):     return topology.errors()
        case .sharded(let topology):    return topology.errors()
        case .replicated(let topology): return topology.errors()
        }
    }
}
extension MongoTopology
{
    private
    init?(host:MongoTopology.Host, channel:MongoChannel, metadata:MongoTopology.Server,
        seedlist:inout MongoTopology.Unknown,
        monitor:(MongoTopology.Host) -> ())
    {
        switch metadata
        {
        case    .standalone(let metadata):
            if  let topology:MongoTopology.Single = .init(host: host,
                    channel: channel,
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
            if  let sharded:MongoTopology.Sharded = .init(host: host,
                    channel: channel,
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
            if  let replicated:MongoTopology.Replicated = .init(host: host,
                    channel: channel,
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
    public mutating
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
    {
        switch self
        {
        case .terminated:
            return false
        
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
    public mutating
    func update(host:MongoTopology.Host, channel:MongoChannel, metadata:MongoTopology.Server,
        monitor:(MongoTopology.Host) -> ()) -> Bool
    {
        switch self
        {
        case .terminated:
            return false
        
        case .unknown(var seeds):
            if  let topology:Self = .init(host: host, channel: channel,
                    metadata: metadata,
                    seedlist: &seeds,
                    monitor: monitor)
            {
                self = topology
                return true
            }
            else
            {
                self = .unknown(seeds)
                return false
            }
        
        case .single(var topology):
            self = .unknown(.init())
            defer
            {
                self = .single(topology)
            }
            if case .standalone(let metadata) = metadata
            {
                return topology.update(host: host, channel: channel, metadata: metadata)
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
                return topology.update(host: host, channel: channel, metadata: metadata)
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
                return topology.update(host: host, channel: channel, metadata: metadata,
                    peerlist: peerlist,
                    monitor: monitor)
            
            case    .replicaGhost:
                //  this is not the same as clearing the descriptor
                return topology.update(host: host, channel: channel, metadata: ())
            
            default:
                // remove and stop monitoring
                return topology.remove(host: host)
            }
        }
    }
}

extension MongoTopology
{
    /// Returns a channel to a master server, if one is available, and
    /// according to the current topology type.
    ///
    /// For ``case single(_:)`` topologies, this will return a channel
    /// to the lone server, if available.
    ///
    /// For ``case sharded(_:)`` topologies, this will return any available
    /// router.
    ///
    /// For ``case replicated(_:)`` topologies, this will return a channel
    /// to the primary replica, if available.
    ///
    /// For ``case unknown(_:)`` topologies, this will always return [`nil`]().
    public
    var master:MongoChannel?
    {
        switch self
        {
        case .terminated, .unknown(_):  return nil
        case .single(let topology):     return topology.master
        case .sharded(let topology):    return topology.any
        case .replicated(let topology): return topology.master
        }
    }
    /// Returns a channel to any data-bearing server, if one is available,
    /// and according to the current topology type.
    ///
    /// For ``case single(_:)`` topologies, this will return a channel
    /// to the lone server, if available.
    ///
    /// For ``case sharded(_:)`` topologies, this will return any available
    /// router.
    ///
    /// For ``case replicated(_:)`` topologies, this will return a channel
    /// to any available primary or secondary replica.
    ///
    /// For ``case unknown(_:)`` topologies, this will always return [`nil`]().
    public
    var any:MongoChannel?
    {
        switch self
        {
        case .terminated, .unknown(_):  return nil
        case .single(let topology):     return topology.master
        case .sharded(let topology):    return topology.any
        case .replicated(let topology): return topology.any
        }
    }
}
