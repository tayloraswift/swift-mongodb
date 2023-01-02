import BSON
import Durations
import MongoChannel
import MongoConnection

extension MongoTopology
{
    public
    struct Replicated
    {
        private
        var members:[Host: MongoConnection<Member?>.State]
        private
        var regime:Regime?
        private
        var name:String

        private
        var primary:Host?

        private
        init(members:[Host: MongoConnection<Member?>.State],
            regime:Regime? = nil,
            name:String)
        {
            self.members = members
            self.regime = regime
            self.name = name

            self.primary = nil
        }
    }
}
extension MongoTopology.Replicated
{
    func snapshot(heartbeatInterval:Milliseconds) -> MongoTopology.Members
    {
        .init(heartbeatInterval: heartbeatInterval, members: self.members)
    }
}
extension MongoTopology.Replicated
{
    func terminate()
    {
        for member:MongoConnection<MongoTopology.Member?>.State in self.members.values
        {
            member.connection?.channel.heart.stop()
        }
    }
}
extension MongoTopology.Replicated
{
    init(from unknown:MongoTopology.Unknown, name:String)
    {
        self.init(members: unknown.topology(of: MongoTopology.Member?.self), name: name)
    }
    mutating
    func remove(host:MongoTopology.Host) -> Bool
    {
        self.members[host].remove()
        self.crown(primary: nil)
        return false
    }
    mutating
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
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
    func update(host:MongoTopology.Host, metadata:Void, channel:MongoChannel) -> Bool
    {
        if  case ()? = self.members[host]?.update(with: .init(metadata: nil,
                channel: channel))
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
    func update(host:MongoTopology.Host, as slave:MongoTopology.Slave,
        peerlist:MongoTopology.Peerlist,
        channel:MongoChannel,
        monitor:(MongoTopology.Host) -> ()) -> Bool
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
            for new:MongoTopology.Host in peerlist.peers().subtracting(self.members.keys)
            {
                self.members[new] = .queued
                monitor(new)
            }
        }

        guard host == peerlist.me
        else
        {
            return self.remove(host: host)
        }

        guard case ()? = self.members[host]?.update(with: .init(
                metadata: slave.metadata,
                channel: channel))
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
    func update(host:MongoTopology.Host, as master:MongoTopology.Master,
        peerlist:MongoTopology.Peerlist,
        channel:MongoChannel,
        monitor:(MongoTopology.Host) -> ()) -> Bool
    {
        guard self.name == peerlist.set
        else
        {
            // not part of this replica set
            return self.remove(host: host)
        }
        if let regime:MongoTopology.Regime = self.regime, master.regime < regime
        {
            // stale primary
            return self.clear(host: host, status: nil)
        }

        guard case ()? = self.members[host]?.update(with: .init(
                metadata: master.metadata,
                channel: channel))
        else
        {
            // not part of topology to begin with
            return false
        }

        defer
        {
            self.crown(primary: host)
        }

        self.regime = master.regime

        var discovered:Set<MongoTopology.Host> = peerlist.peers()
        for old:MongoTopology.Host in self.members.keys
        {
            if case nil = discovered.remove(old)
            {
                self.members[old].remove()
            }
        }
        for new:MongoTopology.Host in discovered
        {
            self.members[new] = .queued
            monitor(new)
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
    func crown(primary hint:MongoTopology.Host?)
    {
        switch (self.primary, hint)
        {
        case (nil, nil): 
            break
        
        case (nil, let new?):
            if case .primary(_)? = self.members[new]?.connection?.metadata
            {
                self.primary = new
            }
        
        case (let old?, let new?):
            guard old != new
            else
            {
                fallthrough
            }
            if case .primary(_)? = self.members[new]?.connection?.metadata
            {
                self.primary = new
            }
            else
            {
                self.primary = nil
            }
            if  let old:Dictionary<MongoTopology.Host,
                        MongoConnection<MongoTopology.Member?>.State>.Index =
                    self.members.index(forKey: old),
                let connection:MongoConnection =
                    self.members.values[old].connection,
                case .primary = connection.metadata
            {
                //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-monitoring.rst#requesting-an-immediate-check
                connection.channel.heart.beat()
                self.members.values[old].clear(status: nil)
            }
        
        case (let old?, nil):
            guard case .primary(_)? = self.members[old]?.connection?.metadata
            else
            {
                self.primary = nil
                break
            }
        }
    }
}
// extension MongoTopology.Replicated
// {
//     public
//     subscript(host:MongoTopology.Host) -> MongoChannel?
//     {
//         self.members[host]?.channel
//     }

//     public
//     subscript(mode:MongoTopology.ReadMode) -> MongoChannel?
//     {
//         var primary:MongoChannel?
//         {
//             self.primary.flatMap { self[$0] }
//         }
//         var secondary:MongoChannel?
//         {
//             // TODO: get rid of the shuffle and replace with something more efficient
//             for member:MongoConnection.State<MongoTopology.Replica?>
//                 in self.members.values.shuffled()
//             {
//                 switch member
//                 {
//                 case .connected(let channel, metadata: .secondary(_)?):
//                     return channel
                
//                 default:
//                     continue
//                 }
//             }
//             return nil
//         }

//         switch mode
//         {
//         case .nearest:              return self.nearest
//         case .primary:              return primary
//         case .primaryPreferred:     return primary ?? secondary
//         case .secondaryPreferred:   return secondary ?? primary
//         case .secondary:            return secondary
//         }
//     }
    
//     /// Returns a channel to any available primary or secondary member.
//     public
//     var nearest:MongoChannel?
//     {
//         // TODO: get rid of the shuffle and replace with something more efficient
//         for member:MongoConnection.State<MongoTopology.Replica?> in self.members.values.shuffled()
//         {
//             switch member
//             {
//             case    .connected(let channel, metadata: .primary(_)?),
//                     .connected(let channel, metadata: .secondary(_)?):
//                 return channel
            
//             default:
//                 continue
//             }
//         }
//         return nil
//     }
// }
