extension Mongo
{
    @frozen public
    enum Topology<Owner> where Owner:AnyObject
    {
        case unknown(Unknown)
        case single(Single)
        case sharded(Sharded)
        case replicated(Replicated)
    }
}
extension Mongo.Topology:Sendable where Owner:Sendable
{
}
extension Mongo.Topology
{
    public
    init(from seedlist:Mongo.Seedlist, hint:Mongo.TopologyHint?)
    {
        switch hint
        {
        case .replicated(set: let name)?:
            self = .replicated(.init(from: seedlist, name: name))

        case nil:
            self = .unknown(.init(from: seedlist))
        }
    }
}
extension Mongo.Topology
{
    public mutating
    func combine(update:Mongo.TopologyUpdate,
        owner:consuming Owner?,
        host:Mongo.Host,
        add:(Mongo.Host) -> ()) -> Mongo.TopologyUpdateResult
    {
        switch consume self
        {
        case .unknown(var unknown):
            guard
            let owner:Owner
            else
            {
                self = .unknown(unknown)
                return .dropped
            }

            switch update
            {
            //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#updateunknownwithstandalone
            case .standalone(let metadata):
                if  unknown.pick(host: host)
                {
                    self = .single(.init(host: host, metadata: metadata, owner: owner))
                    return .accepted
                }
                else
                {
                    self = .unknown(unknown)
                    return .rejected
                }

            case .router(let metadata):
                var sharded:Sharded = .init(from: unknown)
                defer
                {
                    self = .sharded(sharded)
                }
                return sharded[host]?.assign(metadata: metadata, owner: owner) ?? .rejected

            case .primary(let primary, let peerlist):
                var replicated:Replicated = .init(from: unknown, name: peerlist.set)
                defer
                {
                    self = .replicated(replicated)
                }
                if  let metadata:Mongo.ReplicaSetMember = replicated.combine(update: primary,
                        peerlist: peerlist,
                        host: host,
                        add: add)
                {
                    return replicated[host]?.assign(metadata: metadata, owner: owner)
                        ?? .rejected
                }
                else
                {
                    return .rejected
                }

            case .slave(let slave, let peerlist):
                var replicated:Replicated = .init(from: unknown, name: peerlist.set)
                defer
                {
                    self = .replicated(replicated)
                }
                if  let metadata:Mongo.ReplicaSetMember = replicated.combine(update: slave,
                        peerlist: peerlist,
                        host: host,
                        add: add)
                {
                    return replicated[host]?.assign(metadata: metadata, owner: owner)
                        ?? .rejected
                }
                else
                {
                    return .rejected
                }

            //  https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#topologytype-remains-unknown-when-an-rsghost-is-discovered
            case .ghost:
                self = .unknown(unknown)
                return .accepted
            }

        case .single(var topology):
            defer
            {
                self = .single(topology)
            }
            switch update
            {
            case .standalone(let metadata):
                return topology[host]?.assign(metadata: metadata, owner: owner) ?? .rejected

            case .primary, .slave, .ghost, .router:
                // we cannot remove and stop monitoring the only host we know about
                return topology[host]?.assign(error: nil) ?? .rejected
            }

        case .sharded(var topology):
            defer
            {
                self = .sharded(topology)
            }
            switch update
            {
            case .router(let metadata):
                return topology[host]?.assign(metadata: metadata, owner: owner) ?? .rejected

            case .primary, .slave, .ghost, .standalone:
                topology[host] = nil
                return .rejected
            }

        case .replicated(var topology):
            defer
            {
                self = .replicated(topology)
            }

            let metadata:Mongo.ReplicaSetMember?

            switch update
            {
            case .primary(let primary, let peerlist):
                metadata = topology.combine(update: primary, peerlist: peerlist,
                    host: host,
                    add: add)

            case .slave(let slave, let peerlist):
                metadata = topology.combine(update: slave, peerlist: peerlist,
                    host: host,
                    add: add)

            case .ghost:
                metadata = .ghost

            case .router, .standalone:
                topology[host] = nil
                return .rejected
            }

            guard
            let metadata:Mongo.ReplicaSetMember
            else
            {
                return .rejected
            }

            return topology[host]?.assign(metadata: metadata, owner: owner) ?? .rejected
        }
    }
    public mutating
    func combine(error status:(any Error)?, host:Mongo.Host) -> Mongo.TopologyUpdateResult
    {
        switch consume self
        {
        case .unknown(var seedlist):
            defer
            {
                self = .unknown(seedlist)
            }
            return seedlist.combine(error: status, host: host)

        case .single(var topology):
            defer
            {
                self = .single(topology)
            }
            return topology[host]?.assign(error: status) ?? .rejected

        case .sharded(var topology):
            defer
            {
                self = .sharded(topology)
            }
            return topology[host]?.assign(error: status) ?? .rejected

        case .replicated(var topology):
            defer
            {
                self = .replicated(topology)
            }
            return topology[host]?.assign(error: status) ?? .rejected
        }
    }
}
