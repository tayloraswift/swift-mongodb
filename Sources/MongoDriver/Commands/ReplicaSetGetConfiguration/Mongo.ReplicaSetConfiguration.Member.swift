import BSONSchema
import MongoTopology

extension Mongo.ReplicaSetConfiguration
{
    public
    struct Member:Sendable
    {
        public
        let id:Int64
        public
        let rights:MemberRights
        public
        let tags:BSON.Fields
        public
        let host:MongoTopology.Host

        public
        init(id:Int64,
            rights:MemberRights = .citizen(.init()),
            tags:BSON.Fields = .init(),
            host:MongoTopology.Host)
        {
            self.id = id
            self.rights = rights
            self.tags = tags
            self.host = host
        }
    }
}
extension Mongo.ReplicaSetConfiguration.Member:BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        let rights:Mongo.ReplicaSetConfiguration.MemberRights

        if case true? = try bson["arbiterOnly"]?.decode(to: Bool.self)
        {
            rights = .arbiter
        }
        else
        {
            let priority:Double = try bson["priority"]?.decode(to: Double.self) ?? 1
            let votes:Int = try bson["votes"]?.decode(to: Int.self) ?? 1

            if  let citizen:Mongo.ReplicaSetConfiguration.CitizenRights = .init(
                    priority: priority,
                    votes: votes)
            {
                rights = .citizen(citizen)
            }
            else
            {
                rights = .resident(.init(
                    buildsIndexes: try bson["buildIndexes"]?.decode(to: Bool.self) ?? true,
                    isHidden: try bson["hidden"]?.decode(to: Bool.self) ?? false,
                    votes: votes))
            }
        }
        self.init(id: try bson["_id"].decode(to: Int64.self),
            rights: rights,
            tags: try bson["tags"]?.decode(to: BSON.Fields.self) ?? .init(),
            host: try bson["host"].decode(to: MongoTopology.Host.self))
    }
}
extension Mongo.ReplicaSetConfiguration.Member:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["_id"] = self.id

        switch self.rights
        {
        case .resident(let resident):
            bson["buildIndexes"] = resident.buildsIndexes
            bson["hidden"] = resident.isHidden
            bson["votes"] = resident.votes
        
        case .arbiter:
            bson["arbiterOnly"] = true
        
        case .citizen(let citizen):
            bson["priority"] = citizen.priority
            bson["votes"] = citizen.votes
        }

        bson["tags", elide: true] = self.tags
        bson["host"] = self.host
    }
}
