import BSON

extension Mongo.Topology
{
    struct Replicated
    {
        private
        var replicas:[Mongo.Host: Mongo.ConnectionState<Mongo.Replica?>]
        private
        var regime:Mongo.Regime?
        private
        var name:String

        private
        var primary:Mongo.Host?

        private
        init(replicas:[Mongo.Host: Mongo.ConnectionState<Mongo.Replica?>],
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
        for router:Mongo.ConnectionState<Mongo.Replica?> in self.replicas.values
        {
            router.connection?.heart.stop()
        }
    }
}
extension Mongo.Topology.Replicated
{
    init?(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Replica,
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
        guard case ()? = self.update(host: host, connection: connection,
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
    func remove(host:Mongo.Host) -> Void?
    {
        self.replicas[host].remove()
        self.crown(primary: nil)
        return nil
    }
    mutating
    func clear(host:Mongo.Host, status:(any Error)?) -> Void?
    {
        if case ()? = self.replicas[host]?.clear(status: status)
        {
            self.crown(primary: nil)
            return ()
        }
        else
        {
            return nil
        }
    }
    mutating
    func update(host:Mongo.Host, connection:Mongo.Connection, metadata:Void) -> Void?
    {
        if case ()? = self.replicas[host]?.update(connection: connection, metadata: nil)
        {
            self.crown(primary: nil)
            return ()
        }
        else
        {
            return nil
        }
    }
    mutating
    func update(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Replica,
        peerlist:Mongo.Peerlist,
        monitor:(Mongo.Host) -> ()) -> Void?
    {
        guard case ()? = self.replicas[host]?.update(connection: connection, metadata: metadata)
        else
        {
            return nil
        }

        switch (self.primary, metadata)
        {
        case (_,    .primary(let metadata)):
            defer
            {
                self.crown(primary: host)
            }
            return self.update(host: host, connection: connection, metadata: metadata,
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
                return ()
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
                return ()
            }
            else
            {
                return self.replicas[host].remove()
            }
        }
    }
    private mutating
    func update(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Replica.Master,
        peerlist:Mongo.Peerlist,
        monitor:(Mongo.Host) -> ()) -> Void?
    {
        guard self.name == metadata.set
        else
        {
            return self.replicas[host].remove()
        }
        if let regime:Mongo.Regime = self.regime, metadata.regime < regime
        {
            // stale primary
            return self.replicas[host]?.clear(status: nil)
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
        return ()
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
            if  let old:Dictionary<Mongo.Host, Mongo.ConnectionState<Mongo.Replica?>>.Index =
                    self.replicas.index(forKey: old),
                let connection:Mongo.Connection = self.replicas.values[old].primary
            {
                //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-monitoring.rst#requesting-an-immediate-check
                connection.heart.beat()
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
    /// Returns a connection to the primary replica, if available.
    var master:Mongo.Connection?
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
    /// Returns a connection to any available primary or secondary replica.
    var any:Mongo.Connection?
    {
        for replica:Mongo.ConnectionState<Mongo.Replica?> in self.replicas.values
        {
            switch replica
            {
            case    .connected(let connection, metadata: .primary(_)?),
                    .connected(let connection, metadata: .secondary(_)?):
                return connection
            
            default:
                continue
            }
        }
        return nil
    }
}
