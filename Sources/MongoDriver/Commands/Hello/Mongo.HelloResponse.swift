import BSONDecoding
import BSON_Durations
import Durations
import MongoChannel
import MongoTopology
import MongoWire

extension Mongo
{
    //@frozen public
    struct HelloResponse
    {
        /// An array of SASL mechanisms used to create the user's credential or credentials.
        public
        let saslSupportedMechs:Set<Authentication.SASL>?

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
        let token:MongoChannel.Token

        /// The range of versions of the wire protocol that this `mongod` or `mongos`
        /// instance is capable of using to communicate with clients.
        /// This is called `minWireVersion` and `maxWireVersion` in the server reply.
        //public
        //let wireVersions:ClosedRange<MongoWire>

        let sessions:LogicalSessions

        /// Type-specific information about the server which can be used to
        /// update a topology model. This is [`nil`]() if the server type is
        /// unknown, which is expected of replica set ghosts.
        let variant:MongoTopology.Update.Variant?
    }
}
extension Mongo.HelloResponse:BSONDictionaryDecodable
{
    init<Bytes>(bson:BSON.Dictionary<Bytes>) throws
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

        self.saslSupportedMechs = try bson["saslSupportedMechs"]?.decode(
            to: Set<Mongo.Authentication.SASL>.self)

        self.sessions = .init(ttl: try bson["logicalSessionTimeoutMinutes"].decode(
            to: Minutes.self))
        self.maxWriteBatchCount = try bson["maxWriteBatchSize"]?.decode(
            to: Int.self) ?? 100_000
        self.maxDocumentSize = try bson["maxBsonObjectSize"]?.decode(
            to: Int.self) ?? 16 * 1024 * 1024
        self.maxMessageSize = try bson["maxMessageSizeBytes"]?.decode(
            to: Int.self) ?? 48_000_000
        
        self.localTime = try bson["localTime"].decode(to: BSON.Millisecond.self)
        
        self.token = try bson["connectionId"].decode(to: MongoChannel.Token.self)
        
        if  let set:String = try bson["setName"]?.decode(to: String.self)
        {
            let tags:[String: String]? = try bson["tags"]?.decode(
                to: [String: String].self)
            
            let peerlist:MongoTopology.Peerlist = .init(set: set,
                primary: try bson["primary"]?.decode(to: MongoTopology.Host.self),
                arbiters: try bson["arbiters"]?.decode(to: [MongoTopology.Host].self) ?? [],
                passives: try bson["passives"]?.decode(to: [MongoTopology.Host].self) ?? [],
                hosts: try bson["hosts"].decode(to: [MongoTopology.Host].self),
                me: try bson["me"].decode(to: MongoTopology.Host.self))

            if      case true? =
                    try (bson["isWritablePrimary"] ?? bson["ismaster"])?.decode(to: Bool.self)
            {
                self.variant = .master(.init(replica: .init(
                        timings: try bson["lastWrite"].decode(to: MongoTopology.Timings.self),
                        tags: tags ?? [:]),
                    regime: .init(
                        election: try bson["electionId"].decode(to: BSON.Identifier.self),
                        version: try bson["setVersion"].decode(to: Int64.self))),
                    peerlist)
            }
            else if case true? = try bson["secondary"]?.decode(to: Bool.self)
            {
                //  optional if nothing has propogated to this secondary yet
                self.variant = .slave(.secondary(.init(
                        timings: try bson["lastWrite"].decode(to: MongoTopology.Timings.self),
                        tags: tags ?? [:])),
                    peerlist)
            }
            else if case true? = try bson["arbiterOnly"]?.decode(to: Bool.self)
            {
                self.variant = .slave(.arbiter, peerlist)
            }
            else
            {
                self.variant = .slave(.other, peerlist)
            }
        }
        else
        {
            if      case true? = try bson["isreplicaset"]?.decode(to: Bool.self)
            {
                self.variant = nil
            }
            else if case "isdbgrid"? = try bson["msg"]?.decode(to: String.self)
            {
                self.variant = .router(.init())
            }
            else
            {
                self.variant = .standalone(.init())
            }
        }
    }
}
