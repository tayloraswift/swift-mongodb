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
    // public
    // func errors() -> [MongoTopology.Host: any Error]
    // {
    //     switch self
    //     {
    //     case .terminated:               return [:]
    //     case .unknown(let topology):    return topology.errors()
    //     case .single(let topology):     return topology.errors()
    //     case .sharded(let topology):    return topology.errors()
    //     case .replicated(let topology): return topology.errors()
    //     }
    // }
}
extension MongoTopology
{
    var servers:Servers
    {
        switch self
        {
        case .terminated:
            return .none([])
        case .unknown(let unknown):
            return .none(unknown.servers)
        case .single(let single):
            return single.servers
        case .sharded(let sharded):
            return .sharded(sharded.servers)
        case .replicated(let replicated):
            return .replicated(replicated.servers)
        }
    }
}
extension MongoTopology
{
    private
    init?(host:MongoTopology.Host, with update:MongoTopology.Update,
        unknown:inout MongoTopology.Unknown,
        monitor:(MongoTopology.Host) -> ())
    {
        switch update.variant
        {
        case .standalone(let metadata)?:
            //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#updateunknownwithstandalone
            if  unknown.pick(host: host)
            {
                self = .single(.init(host: host, channel: update.channel, metadata: metadata))
            }
            else
            {
                return nil
            }
        
        case .router(let metadata)?:
            var sharded:MongoTopology.Sharded = .init(from: unknown)
            if  sharded.update(host: host, metadata: metadata, channel: update.channel)
            {
                self = .sharded(sharded)
            }
            else
            {
                unknown.pick(host: host)
                return nil
            }
        
        case .master(let master, let peerlist)?:
            var replicated:MongoTopology.Replicated = .init(from: unknown, name: peerlist.set)
            if  replicated.update(host: host, as: master, peerlist: peerlist,
                    channel: update.channel,
                    monitor: monitor)
            {
                self = .replicated(replicated)
            }
            else
            {
                unknown.pick(host: host)
                return nil
            }
        
        case .slave(let slave, let peerlist)?:
            var replicated:MongoTopology.Replicated = .init(from: unknown, name: peerlist.set)
            if  replicated.update(host: host, as: slave, peerlist: peerlist,
                    channel: update.channel,
                    monitor: monitor)
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
    func update(host:MongoTopology.Host, with update:MongoTopology.Update,
        monitor:(MongoTopology.Host) -> ()) -> Bool
    {
        switch self
        {
        case .terminated:
            return false
        
        case .unknown(var unknown):
            if  let topology:Self = .init(host: host, with: update,
                    unknown: &unknown,
                    monitor: monitor)
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
            if case .standalone(let metadata)? = update.variant
            {
                return topology.update(host: host, metadata: metadata,
                    channel: update.channel)
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
            if case .router(let metadata)? = update.variant
            {
                return topology.update(host: host, metadata: metadata,
                    channel: update.channel)
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
            switch update.variant
            {
            case .master(let master, let peerlist)?:
                return topology.update(host: host, as: master, peerlist: peerlist,
                    channel: update.channel,
                    monitor: monitor)
            
            case .slave(let slave, let peerlist)?:
                return topology.update(host: host, as: slave, peerlist: peerlist,
                    channel: update.channel,
                    monitor: monitor)
            
            case nil:
                //  this is not the same as clearing the descriptor
                return topology.update(host: host, metadata: (),
                    channel: update.channel)
            
            default:
                // remove and stop monitoring
                return topology.remove(host: host)
            }
        }
    }
}

// extension MongoTopology
// {
//     /// Returns a channel to a master server, if one is available, and
//     /// according to the current topology type.
//     ///
//     /// For ``case single(_:)`` topologies, this will return a channel
//     /// to the lone server, if available.
//     ///
//     /// For ``case sharded(_:)`` topologies, this will return any available
//     /// router.
//     ///
//     /// For ``case replicated(_:)`` topologies, this will return a channel
//     /// to the primary replica, if available.
//     ///
//     /// For ``case unknown(_:)`` topologies, this will always return [`nil`]().
//     public
//     var master:MongoChannel?
//     {
//         switch self
//         {
//         case .terminated, .unknown(_):  return nil
//         case .single(let topology):     return topology.master
//         case .sharded(let topology):    return topology.any
//         case .replicated(let topology): return topology.master
//         }
//     }
//     /// Returns a channel to any data-bearing server, if one is available,
//     /// and according to the current topology type.
//     ///
//     /// For ``case single(_:)`` topologies, this will return a channel
//     /// to the lone server, if available.
//     ///
//     /// For ``case sharded(_:)`` topologies, this will return any available
//     /// router.
//     ///
//     /// For ``case replicated(_:)`` topologies, this will return a channel
//     /// to any available primary or secondary replica.
//     ///
//     /// For ``case unknown(_:)`` topologies, this will always return [`nil`]().
//     public
//     var any:MongoChannel?
//     {
//         switch self
//         {
//         case .terminated, .unknown(_):  return nil
//         case .single(let topology):     return topology.master
//         case .sharded(let topology):    return topology.any
//         case .replicated(let topology): return topology.any
//         }
//     }
// }
