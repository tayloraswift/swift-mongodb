import BSON
import MongoChannel

extension MongoTopology
{
    public
    struct Replicated
    {
        private
        var replicas:[Host: MongoChannel.State<Replica?>]
        private
        var regime:Regime?
        private
        var name:String

        private
        var primary:Host?

        private
        init(replicas:[Host: MongoChannel.State<Replica?>],
            regime:Regime? = nil,
            name:String)
        {
            self.replicas = replicas
            self.regime = regime
            self.name = name

            self.primary = nil
        }
    }
}
extension MongoTopology.Replicated
{
    func terminate()
    {
        for router:MongoChannel.State<MongoTopology.Replica?> in self.replicas.values
        {
            router.channel?.heart.stop()
        }
    }
    func errors() -> [MongoTopology.Host: any Error]
    {
        self.replicas.compactMapValues(\.error)
    }
}
extension MongoTopology.Replicated
{
    init?(host:MongoTopology.Host, channel:MongoChannel, metadata:MongoTopology.Replica,
        seedlist:inout MongoTopology.Unknown,
        peerlist:MongoTopology.Peerlist,
        monitor:(MongoTopology.Host) -> ())
    {
        switch metadata
        {
        case    .primary(let master):
            self.init(replicas: seedlist.topology(of: MongoTopology.Replica?.self),
                regime: master.regime,
                name: master.set)
        case    .secondary(let slave),
                .arbiter(let slave),
                .other(let slave):
            self.init(replicas: seedlist.topology(of: MongoTopology.Replica?.self),
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
    func remove(host:MongoTopology.Host) -> Bool
    {
        self.replicas[host].remove()
        self.crown(primary: nil)
        return false
    }
    mutating
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
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
    func update(host:MongoTopology.Host, channel:MongoChannel, metadata:Void) -> Bool
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
    func update(host:MongoTopology.Host, channel:MongoChannel,
        metadata:MongoTopology.Replica,
        peerlist:MongoTopology.Peerlist,
        monitor:(MongoTopology.Host) -> ()) -> Bool
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
            for new:MongoTopology.Host in peerlist.peers().subtracting(self.replicas.keys)
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
    func update(host:MongoTopology.Host, channel:MongoChannel,
        metadata:MongoTopology.Replica.Master,
        peerlist:MongoTopology.Peerlist,
        monitor:(MongoTopology.Host) -> ()) -> Bool
    {
        guard self.name == metadata.set
        else
        {
            return self.replicas[host].remove()
        }
        if let regime:MongoTopology.Regime = self.regime, metadata.regime < regime
        {
            // stale primary
            return self.replicas[host]?.clear(status: nil) ?? false
        }
        else
        {
            self.regime = metadata.regime
        }

        var discovered:Set<MongoTopology.Host> = peerlist.peers()
        for old:MongoTopology.Host in self.replicas.keys
        {
            if case nil = discovered.remove(old)
            {
                self.replicas[old].remove()
            }
        }
        for new:MongoTopology.Host in discovered
        {
            self.replicas[new] = .queued
            monitor(new)
        }
        return true
    }
    private mutating
    func crown(primary:MongoTopology.Host?)
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
            if  let old:Dictionary<MongoTopology.Host,
                        MongoChannel.State<MongoTopology.Replica?>>.Index =
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
extension MongoTopology.Replicated
{
    /// Returns a channel to the primary replica, if available.
    public
    var master:MongoChannel?
    {
        if let primary:MongoTopology.Host = self.primary
        {
            return self.replicas[primary]?.primary
        }
        else
        {
            return nil
        }
    }
    /// Returns a channel to any available primary or secondary replica.
    public
    var any:MongoChannel?
    {
        for replica:MongoChannel.State<MongoTopology.Replica?> in self.replicas.values
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
