import BSONDecoding
import MongoWire

extension Mongo
{
    //@frozen public
    struct ServerMetadata
    {
        /// The maximum permitted size of a BSON object in bytes for this
        /// [mongod](https://www.mongodb.com/docs/manual/reference/program/mongod/#mongodb-binary-bin.mongod)
        /// process.
        public
        let maxBsonObjectSize:Int

        /// The maximum permitted size of a BSON wire protocol message. 
        public
        let maxMessageSizeBytes:Int

        /// The maximum number of write operations permitted in a write batch.
        public
        let maxWriteBatchSize:Int

        /// Returns the local server time in UTC. This value is an
        /// [ISO date](https://www.mongodb.com/docs/manual/reference/glossary/#std-term-ISODate).
        public
        let localTime:BSON.Millisecond

        /// The time in minutes that a
        /// [session](https://www.mongodb.com/docs/manual/core/read-isolation-consistency-recency/#std-label-sessions)
        /// remains active after its most recent use. Sessions that have not received
        /// a new read/write operation from the client or been refreshed with
        /// [`refreshSessions`](https://www.mongodb.com/docs/manual/reference/command/refreshSessions/#mongodb-dbcommand-dbcmd.refreshSessions)
        /// within this threshold are cleared from the cache. State associated with
        /// an expired session may be cleaned up by the server at any time.
        public
        let logicalSessionTimeoutMinutes:Minutes

        /// An identifier for the `mongod`/`mongos` instance's outgoing connection
        /// to the client.
        /// This is called `connectionId` in the server reply.
        public
        let token:ConnectionToken

        /// The range of versions of the wire protocol that this `mongod` or `mongos`
        /// instance is capable of using to communicate with clients.
        /// This is called `minWireVersion` and `maxWireVersion` in the server reply.
        //public
        //let wireVersions:ClosedRange<MongoWire>

        /// An array of SASL mechanisms used to create the user's credential or credentials.
        public
        let saslSupportedMechs:Set<Authentication.SASL>?

        let type:Server
    }
}
extension Mongo.ServerMetadata:BSONDictionaryDecodable
{
    public
    init<Bytes>(bson:BSON.Dictionary<Bytes>) throws
    {
        //self.isWritablePrimary = try bson["isWritablePrimary"].decode(to: Bool.self)

        self.maxBsonObjectSize = try bson["maxBsonObjectSize"]?.decode(
            to: Int.self) ?? 16 * 1024 * 1024
        self.maxMessageSizeBytes = try bson["maxMessageSizeBytes"]?.decode(
            to: Int.self) ?? 48_000_000
        self.maxWriteBatchSize = try bson["maxWriteBatchSize"]?.decode(
            to: Int.self) ?? 100_000
        
        self.localTime = try bson["localTime"].decode(to: BSON.Millisecond.self)
        self.logicalSessionTimeoutMinutes = try bson["logicalSessionTimeoutMinutes"].decode(
            to: Mongo.Minutes.self)
        
        self.token = try bson["connectionId"].decode(to: Mongo.ConnectionToken.self)
        
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

        if let set:String = try bson["setName"]?.decode(to: String.self)
        {
            let tags:BSON.Fields = try bson["tags"]?.decode(to: BSON.Fields.self) ?? .init()
            let peerlist:Mongo.Peerlist = .init(
                primary: try bson["primary"].decode(to: Mongo.Host.self),
                arbiters: try bson["arbiters"]?.decode(to: [Mongo.Host].self) ?? [],
                passives: try bson["passives"]?.decode(to: [Mongo.Host].self) ?? [],
                hosts: try bson["hosts"].decode(to: [Mongo.Host].self),
                me: try bson["me"].decode(to: Mongo.Host.self))

            if      case true? =
                    try (bson["isWritablePrimary"] ?? bson["ismaster"])?.decode(to: Bool.self)
            {
                self.type = .replica(.primary(.init(regime: .init(
                            election: try bson["electionId"].decode(to: BSON.Identifier.self),
                            version: try bson["setVersion"].decode(to: Int64.self)),
                        tags: tags,
                        set: set)),
                    peerlist)
            }
            else if case true? = try bson["secondary"]?.decode(to: Bool.self)
            {
                self.type = .replica(.secondary(.init(tags: tags, set: set)), peerlist)
            }
            else if case true? = try bson["arbiterOnly"]?.decode(to: Bool.self)
            {
                self.type = .replica(.arbiter(.init(tags: tags, set: set)), peerlist)
            }
            else
            {
                self.type = .replica(.other(.init(tags: tags, set: set)), peerlist)
            }
        }
        else
        {
            if      case true? = try bson["isreplicaset"]?.decode(to: Bool.self)
            {
                self.type = .replicaGhost
            }
            else if case "isdbgrid"? = try bson["msg"]?.decode(to: String.self)
            {
                self.type = .router(.init())
            }
            else
            {
                self.type = .single(.init())
            }
        }
    }
}
