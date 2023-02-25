import MongoMonitoring

extension Mongo.Topology
{
    public
    struct Replicated
    {
        //public private(set)
        private
        var members:[Mongo.Host: Mongo.ServerDescription<Mongo.ReplicaSetMember, Owner>]
        private
        var term:Mongo.ReplicaSetTerm?
        private
        var name:String

        private
        var primary:Mongo.Host?

        private
        init(members:[Mongo.Host: Mongo.ServerDescription<Mongo.ReplicaSetMember, Owner>],
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
extension Mongo.Topology.Replicated:Sendable where Owner:Sendable
{
}
extension Mongo.Topology.Replicated
{
    public
    subscript(host:Mongo.Host) -> Mongo.ServerDescription<Mongo.ReplicaSetMember, Owner>?
    {
        _read
        {
            yield self.members[host]
        }
        set(value)
        {
            defer
            {
                self.members[host] = value
            }
            if case .primary? = value?.metadata
            {
                switch self.primary
                {
                case host?:
                    //  Setting the primary to a primary. Nothing to do.
                    break

                case let old?:
                    //  Setting a slave to a primary. We need to invalidate
                    //  the old primary, and update the name of the primary.
                    {
                        if  let owner:Owner = $0?.owner
                        {
                            $0 = .connected(.ghost, owner)
                        }
                    }   (&self.members[old])

                    self.primary = host
                
                case nil:
                    //  Adding a primary to a replica set that didn’t have
                    //  one already.
                    self.primary = host
                }
            }
            else
            {
                switch self.primary
                {
                case host?:
                    //  Setting the primary to a slave (or deleting it).
                    //  We need to clear the name of the primary.
                    self.primary = nil

                case _:
                    //  Assignment has nothing to do with primaries.
                    break
                }
            }
        }
    }
}
extension Mongo.Topology.Replicated
{
    init(from unknown:Mongo.Topology<Owner>.Unknown, name:String)
    {
        self.init(members: unknown.topology(of: Mongo.ReplicaSetMember.self), name: name)
    }
    // mutating
    // func remove(host:Mongo.Host) -> Mongo.TopologyUpdateResult
    // {
    //     self.members[host].remove()
    //     self.crown(primary: nil)
    //     return .rejected
    // }
    // mutating
    // func combine(error status:(any Error)?,
    //     host:Mongo.Host) -> Mongo.TopologyUpdateResult
    // {

    //     // if case ()? = self.members[host]?.clear(status: status)
    //     // {
    //     //     self.crown(primary: nil)
    //     //     return .accepted
    //     // }
    //     // else
    //     // {
    //     //     return .rejected
    //     // }
    // }

    // mutating
    // func combine(update:Mongo.Ghost,
    //     owner:Owner,
    //     host:Mongo.Host) -> Mongo.TopologyUpdateResult
    // {
    //     if  case ()? = self.members[host]?.update(with: .ghost, pool: pool)
    //     {
    //         self.crown(primary: nil)
    //         return .accepted
    //     } 
    //     else
    //     {
    //         return .rejected
    //     }
    // }
    mutating
    func combine(update:Mongo.TopologyUpdate.Primary,
        peerlist:Mongo.Peerlist,
        host:Mongo.Host,
        add:(Mongo.Host) -> ()) -> Mongo.ReplicaSetMember?
    {
        guard self.name == peerlist.set
        else
        {
            //  Not part of this replica set.
            self[host] = nil
            return nil
        }

        if update.newer(than: &self.term)
        {
            //  Always use the peerlist, even if we end up rejecting the update.
            var discovered:Set<Mongo.Host> = peerlist.peers()

            for host:Mongo.Host in self.members.keys where
                discovered.remove(host) == nil
            {
                self[host] = nil
            }
            for host:Mongo.Host in discovered
            {
                self[host] = .queued
                add(host)
            }

            return update.metadata
        }
        else
        {
            //  Stale primary. The spec says to drain the pool, but I think
            //  it is better to just mark the server a ghost, and let the next
            //  streaming hello update it with its new state.
            return .ghost
        }

        //return self[host]?.assign(metadata: metadata, owner: owner) ?? .rejected
    }

    mutating
    func combine(update:Mongo.TopologyUpdate.Slave,
        peerlist:Mongo.Peerlist,
        host:Mongo.Host,
        add:(Mongo.Host) -> ()) -> Mongo.ReplicaSetMember?
    {
        guard self.name == peerlist.set
        else
        {
            //  Not part of this replica set.
            self[host] = nil
            return nil
        }

        if case nil = self.primary
        {            
            //  Always use the peerlist, even if we end up rejecting the update.
            for host:Mongo.Host in peerlist.peers(besides: self.members.keys)
            {
                self[host] = .queued
                add(host)
            }
        }

        guard host == peerlist.me
        else
        {
            self[host] = nil
            return nil
        }

        return update.metadata
        //return self[host]?.assign(metadata: update.metadata, owner: owner) ?? .rejected
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
    // private mutating
    // func crown(primary hint:Mongo.Host?)
    // {
    //     switch (self.primary, hint)
    //     {
    //     case (nil, nil): 
    //         break
        
    //     case (nil, let new?):
    //         if case .primary(_)? = self.members[new]?.metadata
    //         {
    //             self.primary = new
    //         }
        
    //     case (let old?, let new?):
    //         guard old != new
    //         else
    //         {
    //             fallthrough
    //         }
    //         if case .primary(_)? = self.members[new]?.metadata
    //         {
    //             self.primary = new
    //         }
    //         else
    //         {
    //             self.primary = nil
    //         }
    //         if  let old:Dictionary<Mongo.Host,
    //                     Mongo.ServerDescription<Mongo.ReplicaSetMember, Pool>>.Index =
    //                 self.members.index(forKey: old),
    //             case .monitoring(.primary(_), let pool) = self.members.values[old]
    //         {
    //             //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-monitoring.rst#requesting-an-immediate-check
    //             pool.requestRecheck()
    //             self.members.values[old] = .monitoring(.ghost, pool)
    //         }
        
    //     case (let old?, nil):
    //         guard case .primary(_)? = self.members[old]?.metadata
    //         else
    //         {
    //             self.primary = nil
    //             break
    //         }
    //     }
    // }
}
