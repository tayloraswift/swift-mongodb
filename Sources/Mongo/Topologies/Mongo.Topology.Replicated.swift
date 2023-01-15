import MongoMonitoringDelegate

extension Mongo.Topology
{
    public
    struct Replicated
    {
        public private(set)
        var members:[Mongo.Host: Mongo.ServerDescription<Mongo.ReplicaSetMember?, Pool>]
        private
        var term:Mongo.ReplicaSetTerm?
        private
        var name:String

        private
        var primary:Mongo.Host?

        private
        init(members:[Mongo.Host: Mongo.ServerDescription<Mongo.ReplicaSetMember?, Pool>],
            term:Mongo.ReplicaSetTerm? = nil,
            name:String)
        {
            self.members = members
            self.term = term
            self.name = name

            self.primary = nil
        }
    }
}
extension Mongo.Topology.Replicated
{
    init(from unknown:Mongo.Topology<Pool>.Unknown, name:String)
    {
        self.init(members: unknown.topology(of: Mongo.ReplicaSetMember?.self), name: name)
    }
    mutating
    func remove(host:Mongo.Host) -> Bool
    {
        self.members[host].remove()
        self.crown(primary: nil)
        return false
    }
    mutating
    func combine(error status:(any Error)?, host:Mongo.Host) -> Bool
    {
        if case ()? = self.members[host]?.clear(status: status)
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
    func combine(metadata:Void, host:Mongo.Host, pool:Pool) -> Bool
    {
        if  case ()? = self.members[host]?.update(with: nil, pool: pool)
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
    func combine(update:Mongo.TopologyUpdate.Slave,
        peerlist:Mongo.Peerlist,
        host:Mongo.Host,
        pool:Pool,
        add:(Mongo.Host) -> ()) -> Bool
    {
        guard self.name == peerlist.set
        else
        {
            // not part of this replica set
            return self.remove(host: host)
        }

        if case nil = self.primary
        {            
            // use the peerlist, even if the `me` field is wrong
            for new:Mongo.Host in peerlist.peers().subtracting(self.members.keys)
            {
                self.members[new] = .queued
                add(new)
            }
        }

        guard host == peerlist.me
        else
        {
            return self.remove(host: host)
        }

        guard case ()? = self.members[host]?.update(with: update.metadata, pool: pool)
        else
        {
            return false
        }

        defer
        {
            self.crown(primary: nil)
        }

        return true
    }
    mutating
    func combine(update:Mongo.TopologyUpdate.Master,
        peerlist:Mongo.Peerlist,
        host:Mongo.Host,
        pool:Pool,
        add:(Mongo.Host) -> ()) -> Bool
    {
        guard self.name == peerlist.set
        else
        {
            // not part of this replica set
            return self.remove(host: host)
        }
        if let term:Mongo.ReplicaSetTerm = self.term, update.term < term
        {
            // stale primary
            return self.combine(error: nil, host: host)
        }

        guard case ()? = self.members[host]?.update(with: update.metadata, pool: pool)
        else
        {
            // not part of topology to begin with
            return false
        }

        defer
        {
            self.crown(primary: host)
        }

        self.term = update.term

        var discovered:Set<Mongo.Host> = peerlist.peers()
        for old:Mongo.Host in self.members.keys
        {
            if case nil = discovered.remove(old)
            {
                self.members[old].remove()
            }
        }
        for new:Mongo.Host in discovered
        {
            self.members[new] = .queued
            add(new)
        }

        return true
    }

    /// Checks if the current ``primary`` host still refers to a primary,
    /// and if a hint is provided, checks if the new host actually
    /// refers to a primary. Always updates this topology’s ``primary``
    /// property accordingly.
    ///
    /// If the old primary still refers to a primary (e.g., it was not
    /// preemptively removed or cleared) *and* a hint is provided,
    /// this method will trigger a heartbeat on the old primary and then
    /// clear its descriptor, regardless of the validity of the hint.
    /// (The hint may be invalid because the new primary may have been
    /// temporarily removed from the topology because it would like to
    /// be referred to by a host name that is different than the one the
    /// connection was seeded with.)
    ///
    /// This method guarantees that ``primary`` points to a primary replica
    /// after returning. Moreover, if `hint` was the only host whose
    /// metadata was ever (optionally) assigned to ``case Member.primary(_:)``
    /// between calls to this method, it guarantees that the topology
    /// contains *at most* one primary, and that ``primary`` points to that
    /// member if it exists.
    private mutating
    func crown(primary hint:Mongo.Host?)
    {
        switch (self.primary, hint)
        {
        case (nil, nil): 
            break
        
        case (nil, let new?):
            if case .primary(_)? = self.members[new]?.metadata
            {
                self.primary = new
            }
        
        case (let old?, let new?):
            guard old != new
            else
            {
                fallthrough
            }
            if case .primary(_)? = self.members[new]?.metadata
            {
                self.primary = new
            }
            else
            {
                self.primary = nil
            }
            if  let old:Dictionary<Mongo.Host,
                        Mongo.ServerDescription<Mongo.ReplicaSetMember?, Pool>>.Index =
                    self.members.index(forKey: old),
                case .monitoring(.primary(_)?, let pool) = self.members.values[old]
            {
                //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-monitoring.rst#requesting-an-immediate-check
                pool.requestRecheck()
                self.members.values[old].clear(status: nil)
            }
        
        case (let old?, nil):
            guard case .primary(_)? = self.members[old]?.metadata
            else
            {
                self.primary = nil
                break
            }
        }
    }
}
