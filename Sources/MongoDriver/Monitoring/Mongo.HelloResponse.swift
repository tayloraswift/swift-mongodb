import BSONDecoding
import BSON_Durations
import Durations
import MongoWire

extension Mongo
{
    struct HelloResponse
    {
        /// The maximum number of write operations permitted in a write batch.
        public
        let maxWriteBatchCount:Int

        /// The maximum permitted size of a BSON object in bytes for this
        /// [mongod](https://www.mongodb.com/docs/manual/reference/program/mongod/#mongodb-binary-bin.mongod)
        /// process.
        public
        let maxDocumentSize:Int

        /// The maximum permitted size of a BSON wire protocol message. 
        public
        let maxMessageSize:Int

        /// Returns the local server time in UTC. This value is an
        /// [ISO date](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-ISODate).
        public
        let localTime:BSON.Millisecond

        /// An identifier for the `mongod`/`mongos` instance's outgoing connection
        /// to the client.
        /// This is called `connectionId` in the server reply.
        public
        let token:Mongo.ConnectionToken

        /// The range of versions of the wire protocol that this `mongod` or `mongos`
        /// instance is capable of using to communicate with clients.
        /// This is called `minWireVersion` and `maxWireVersion` in the server reply.
        //public
        //let wireVersions:ClosedRange<MongoWire>

        let sessions:Mongo.LogicalSessions

        /// Type-specific information about the server which can be used to
        /// update a topology model.
        let update:Mongo.TopologyUpdate
    }
}
extension Mongo.HelloResponse:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<BSON.Key, some RandomAccessCollection<UInt8>>) throws
    {
        let minWireVersion:MongoWire = try bson["minWireVersion"].decode(as: Int32.self,
            with: MongoWire.init(rawValue:))
        let maxWireVersion:MongoWire = try bson["maxWireVersion"].decode(as: Int32.self,
            with: MongoWire.init(rawValue:))
        
        //  consider maxWireVersion authoritative
        guard maxWireVersion >= 17
        else
        {
            throw Mongo.VersionRequirementError.init(
                invalid: min(minWireVersion, maxWireVersion) ... maxWireVersion)
        }

        self.sessions = .init(ttl: try bson["logicalSessionTimeoutMinutes"].decode(
            to: Minutes.self))
        self.maxWriteBatchCount = try bson["maxWriteBatchSize"]?.decode(
            to: Int.self) ?? 100_000
        self.maxDocumentSize = try bson["maxBsonObjectSize"]?.decode(
            to: Int.self) ?? 16 * 1024 * 1024
        self.maxMessageSize = try bson["maxMessageSizeBytes"]?.decode(
            to: Int.self) ?? 48_000_000
        
        self.localTime = try bson["localTime"].decode(to: BSON.Millisecond.self)
        
        self.token = try bson["connectionId"].decode(to: Mongo.ConnectionToken.self)
        
        if  let set:String = try bson["setName"]?.decode(to: String.self)
        {
            let tags:[String: String]? = try bson["tags"]?.decode(
                to: [String: String].self)
            
            let peerlist:Mongo.Peerlist = .init(set: set,
                primary: try bson["primary"]?.decode(to: Mongo.Host.self),
                arbiters: try bson["arbiters"]?.decode(to: [Mongo.Host].self) ?? [],
                passives: try bson["passives"]?.decode(to: [Mongo.Host].self) ?? [],
                hosts: try bson["hosts"].decode(to: [Mongo.Host].self),
                me: try bson["me"].decode(to: Mongo.Host.self))

            if      case true? =
                    try (bson["isWritablePrimary"] ?? bson["ismaster"])?.decode(to: Bool.self)
            {
                let replica:Mongo.Replica = .init(
                    timings: try bson["lastWrite"].decode(to: Mongo.Replica.Timings.self),
                    tags: tags ?? [:])
                self.update = .primary(.init(replica: replica, term: .init(
                        election: try bson["electionId"].decode(to: BSON.Identifier.self),
                        version: try bson["setVersion"].decode(to: Int64.self))),
                    peerlist)
            }
            else if case true? = try bson["secondary"]?.decode(to: Bool.self)
            {
                let replica:Mongo.Replica = .init(
                    timings: try bson["lastWrite"].decode(to: Mongo.Replica.Timings.self),
                    tags: tags ?? [:])
                self.update = .slave(.secondary(replica), peerlist)
            }
            else if case true? = try bson["arbiterOnly"]?.decode(to: Bool.self)
            {
                self.update = .slave(.arbiter, peerlist)
            }
            else
            {
                self.update = .slave(.other, peerlist)
            }
        }
        else
        {
            if      case true? = try bson["isreplicaset"]?.decode(to: Bool.self)
            {
                self.update = .ghost
            }
            else if case "isdbgrid"? = try bson["msg"]?.decode(to: String.self)
            {
                self.update = .router(.router)
            }
            else
            {
                self.update = .standalone(.standalone)
            }
        }
    }
}
