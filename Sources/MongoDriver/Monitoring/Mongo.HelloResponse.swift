import BSON
import MongoWire
import UnixTime

extension Mongo
{
    struct HelloResponse
    {
        /// The version associated with the ``topologyUpdate``. The driver caches this
        /// and sends this as part of an awaitable ``Hello`` command. The server uses it
        /// to determine if the driver’s view of the topology is out of date, and if it
        /// should send an update.
        let topologyVersion:TopologyVersion
        /// Type-specific information about the server and its role in a topology model.
        let topologyUpdate:TopologyUpdate
        /// Returns the local server time in UTC. This value is an
        /// [ISO
        /// date](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-ISODate).
        let localTime:UnixMillisecond

        init(topologyVersion:TopologyVersion,
            topologyUpdate:TopologyUpdate,
            localTime:UnixMillisecond)
        {
            self.topologyVersion = topologyVersion
            self.topologyUpdate = topologyUpdate
            self.localTime = localTime
        }
    }
}
extension Mongo.HelloResponse:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<BSON.Key>) throws
    {
        let minWireVersion:Mongo.WireVersion = try bson["minWireVersion"].decode()
        let maxWireVersion:Mongo.WireVersion = try bson["maxWireVersion"].decode()

        //  consider maxWireVersion authoritative
        guard maxWireVersion >= 17
        else
        {
            throw Mongo.VersionRequirementError.init(
                invalid: min(minWireVersion, maxWireVersion) ... maxWireVersion)
        }

        func capabilities() throws -> Mongo.ServerCapabilities
        {
            .init(
                logicalSessionTimeoutMinutes: try bson["logicalSessionTimeoutMinutes"].decode(
                    to: UInt32.self),
                maxWriteBatchCount: try bson["maxWriteBatchSize"]?.decode(
                    to: Int.self) ?? 100_000,
                maxDocumentSize: try bson["maxBsonObjectSize"]?.decode(
                    to: Int.self) ?? 16 * 1024 * 1024,
                maxMessageSize: try bson["maxMessageSizeBytes"]?.decode(
                    to: Int.self) ?? 48_000_000)
        }

        let topologyUpdate:Mongo.TopologyUpdate

        if  let set:String = try bson["setName"]?.decode(to: String.self)
        {
            let tags:[BSON.Key: String]? = try bson["tags"]?.decode()

            let peerlist:Mongo.Peerlist = .init(set: set,
                primary: try bson["primary"]?.decode(to: Mongo.Host.self),
                arbiters: try bson["arbiters"]?.decode(to: [Mongo.Host].self) ?? [],
                passives: try bson["passives"]?.decode(to: [Mongo.Host].self) ?? [],
                hosts: try bson["hosts"].decode(to: [Mongo.Host].self),
                me: try bson["me"].decode(to: Mongo.Host.self))

            if  case true? = try (bson["isWritablePrimary"] ?? bson["ismaster"])?.decode(
                to: Bool.self)
            {
                let replica:Mongo.Replica = .init(capabilities: try capabilities(),
                    timings: try bson["lastWrite"].decode(to: Mongo.ReplicaTimings.self),
                    tags: tags ?? [:])
                topologyUpdate = .primary(.init(replica: replica, term: .init(
                        election: try bson["electionId"].decode(to: BSON.Identifier.self),
                        version: try bson["setVersion"].decode(to: Int64.self))),
                    peerlist)
            }
            else if
                case true? = try bson["secondary"]?.decode(to: Bool.self)
            {
                let replica:Mongo.Replica = .init(capabilities: try capabilities(),
                    timings: try bson["lastWrite"].decode(to: Mongo.ReplicaTimings.self),
                    tags: tags ?? [:])
                topologyUpdate = .slave(.secondary(replica), peerlist)
            }
            else if
                case true? = try bson["arbiterOnly"]?.decode(to: Bool.self)
            {
                topologyUpdate = .slave(.arbiter, peerlist)
            }
            else
            {
                topologyUpdate = .slave(.other, peerlist)
            }
        }
        else
        {
            if  case true? = try bson["isreplicaset"]?.decode(to: Bool.self)
            {
                topologyUpdate = .ghost
            }
            else if
                case "isdbgrid"? = try bson["msg"]?.decode(to: String.self)
            {
                topologyUpdate = .router(.init(capabilities: try capabilities()))
            }
            else
            {
                topologyUpdate = .standalone(.init(capabilities: try capabilities()))
            }
        }

        self.init(
            topologyVersion: try bson["topologyVersion"].decode(
                to: Mongo.TopologyVersion.self),
            topologyUpdate: topologyUpdate,
            localTime: try bson["localTime"].decode(
                to: UnixMillisecond.self))
    }
}
