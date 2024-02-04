extension Mongo.Topology
{
    public
    struct Replicated
    {
        /// The members of the replica set.
        private
        var members:[Mongo.Host: Mongo.ServerDescription<Mongo.ReplicaSetMember, Owner>]
        /// The current term of the replica set.
        private
        var term:Mongo.ReplicaSetTerm?
        /// The name of the replica set.
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
extension Mongo.Topology.Replicated:Sequence
{
    public
    func makeIterator() -> Dictionary<Mongo.Host,
        Mongo.ServerDescription<Mongo.ReplicaSetMember, Owner>>.Iterator
    {
        self.members.makeIterator()
    }
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
            if  case .primary? = value?.metadata
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
                    } (&self.members[old])

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
    init(from seedlist:Mongo.Seedlist, name:String)
    {
        self.init(members: seedlist.dictionary(repeating: .queued), name: name)
    }
    init(from unknown:Mongo.Topology<Owner>.Unknown, name:String)
    {
        self.init(members: unknown.topology(of: Mongo.ReplicaSetMember.self), name: name)
    }

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

        if  update.newer(than: &self.term)
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

        if  case nil = self.primary
        {
            //  Always use the peerlist, even if we end up rejecting the update.
            for host:Mongo.Host in peerlist.peers(besides: self.members.keys)
            {
                self[host] = .queued
                add(host)
            }
        }

        //  We have called this slave by the wrong name, which is bad apparently.
        guard host == peerlist.me
        else
        {
            self[host] = nil
            return nil
        }

        return update.metadata
    }
}
