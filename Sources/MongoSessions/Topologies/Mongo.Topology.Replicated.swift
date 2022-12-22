import BSON
import MongoChannel

extension Mongo.Topology
{
    struct Replicated
    {
        private
        var replicas:[Mongo.Host: MongoChannel.State<Mongo.Replica?>]
        private
        var regime:Mongo.Regime?
        private
        var name:String

        private
        var primary:Mongo.Host?

        private
        init(replicas:[Mongo.Host: MongoChannel.State<Mongo.Replica?>],
            regime:Mongo.Regime? = nil,
            name:String)
        {
            self.replicas = replicas
            self.regime = regime
            self.name = name

            self.primary = nil
        }
    }
}
extension Mongo.Topology.Replicated
{
    func terminate()
    {
        for router:MongoChannel.State<Mongo.Replica?> in self.replicas.values
        {
            router.channel?.heart.stop()
        }
    }
    func errors() -> [Mongo.Host: any Error]
    {
        self.replicas.compactMapValues(\.error)
    }
}
extension Mongo.Topology.Replicated
{
    init?(host:Mongo.Host, channel:MongoChannel, metadata:Mongo.Replica,
        seedlist:inout Mongo.Seedlist,
        peerlist:Mongo.Peerlist,
        monitor:(Mongo.Host) -> ())
    {
        switch metadata
        {
        case    .primary(let master):
            self.init(replicas: seedlist.topology(of: Mongo.Replica?.self),
                regime: master.regime,
                name: master.set)
        case    .secondary(let slave),
                .arbiter(let slave),
                .other(let slave):
            self.init(replicas: seedlist.topology(of: Mongo.Replica?.self),
                name: slave.set)
        }
        guard   self.update(host: host, channel: channel,
                    metadata: metadata,
                    peerlist: peerlist,
                    monitor: monitor)
        else
        {
            seedlist.pick(host: host)
            return nil
        }
    }
    mutating
    func remove(host:Mongo.Host) -> Bool
    {
        self.replicas[host].remove()
        self.crown(primary: nil)
        return false
    }
    mutating
    func clear(host:Mongo.Host, status:(any Error)?) -> Bool
    {
        if case true? = self.replicas[host]?.clear(status: status)
        {
            self.crown(primary: nil)
            return true
        }
        else
        {
            return false
        }
    }
    mutating
    func update(host:Mongo.Host, channel:MongoChannel, metadata:Void) -> Bool
    {
        if case true? = self.replicas[host]?.update(channel: channel, metadata: nil)
        {
            self.crown(primary: nil)
            return true
        }
        else
        {
            return false
        }
    }
    mutating
    func update(host:Mongo.Host, channel:MongoChannel, metadata:Mongo.Replica,
        peerlist:Mongo.Peerlist,
        monitor:(Mongo.Host) -> ()) -> Bool
    {
        guard case true? = self.replicas[host]?.update(channel: channel, metadata: metadata)
        else
        {
            return false
        }

        switch (self.primary, metadata)
        {
        case (_,    .primary(let metadata)):
            defer
            {
                self.crown(primary: host)
            }
            return self.update(host: host, channel: channel, metadata: metadata,
                peerlist: peerlist,
                monitor: monitor)
            
        case (_?,   .secondary(let metadata)),
             (_?,   .arbiter(let metadata)),
             (_?,   .other(let metadata)):
            defer
            {
                self.crown(primary: nil)
            }
            if self.name == metadata.set, host == peerlist.me
            {
                return true
            }
            else
            {
                return self.replicas[host].remove()
            }
            
        case (nil,  .secondary(let metadata)),
             (nil,  .arbiter(let metadata)),
             (nil,  .other(let metadata)):
            guard self.name == metadata.set
            else
            {
                return self.replicas[host].remove()
            }
            // always use the peerlist, even if the `me` field is wrong
            for new:Mongo.Host in peerlist.peers().subtracting(self.replicas.keys)
            {
                self.replicas[new] = .queued
                monitor(new)
            }
            if host == peerlist.me
            {
                return true
            }
            else
            {
                return self.replicas[host].remove()
            }
        }
    }
    private mutating
    func update(host:Mongo.Host, channel:MongoChannel, metadata:Mongo.Replica.Master,
        peerlist:Mongo.Peerlist,
        monitor:(Mongo.Host) -> ()) -> Bool
    {
        guard self.name == metadata.set
        else
        {
            return self.replicas[host].remove()
        }
        if let regime:Mongo.Regime = self.regime, metadata.regime < regime
        {
            // stale primary
            return self.replicas[host]?.clear(status: nil) ?? false
        }
        else
        {
            self.regime = metadata.regime
        }

        var discovered:Set<Mongo.Host> = peerlist.peers()
        for old:Mongo.Host in self.replicas.keys
        {
            if case nil = discovered.remove(old)
            {
                self.replicas[old].remove()
            }
        }
        for new:Mongo.Host in discovered
        {
            self.replicas[new] = .queued
            monitor(new)
        }
        return true
    }
    private mutating
    func crown(primary:Mongo.Host?)
    {
        switch (self.primary, primary)
        {
        case (nil, nil): 
            break
        
        case (nil, let new?):
            if case .primary(_)?? = self.replicas[new]?.metadata
            {
                self.primary = new
            }
        
        case (let old?, let new?):
            guard old != new
            else
            {
                fallthrough
            }
            if case .primary(_)?? = self.replicas[new]?.metadata
            {
                self.primary = new
            }
            else
            {
                self.primary = nil
            }
            if  let old:Dictionary<Mongo.Host, MongoChannel.State<Mongo.Replica?>>.Index =
                    self.replicas.index(forKey: old),
                let channel:MongoChannel = self.replicas.values[old].primary
            {
                //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-monitoring.rst#requesting-an-immediate-check
                channel.heart.beat()
                self.replicas.values[old].clear(status: nil)
            }
        
        case (let old?, nil):
            guard case .primary(_)?? = self.replicas[old]?.metadata
            else
            {
                self.primary = nil
                break
            }
        }
    }
}
extension Mongo.Topology.Replicated
{
    /// Returns a channel to the primary replica, if available.
    var master:MongoChannel?
    {
        if let primary:Mongo.Host = self.primary
        {
            return self.replicas[primary]?.primary
        }
        else
        {
            return nil
        }
    }
    /// Returns a channel to any available primary or secondary replica.
    var any:MongoChannel?
    {
        for replica:MongoChannel.State<Mongo.Replica?> in self.replicas.values
        {
            switch replica
            {
            case    .connected(let channel, metadata: .primary(_)?),
                    .connected(let channel, metadata: .secondary(_)?):
                return channel
            
            default:
                continue
            }
        }
        return nil
    }
}
