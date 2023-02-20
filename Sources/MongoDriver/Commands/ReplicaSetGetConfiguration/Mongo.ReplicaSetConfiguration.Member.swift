import BSONDecoding
import BSONEncoding
import BSON_Durations
import BSON_OrderedCollections
import Durations
import OrderedCollections

extension OrderedDictionary:@unchecked Sendable where Key:Sendable, Value:Sendable
{
}

extension Mongo.ReplicaSetConfiguration
{
    public
    struct Member:Equatable, Identifiable, Sendable
    {
        public
        let id:Int64
        public
        let host:Mongo.Host
        /// Information about this member if it is a replica, [`nil`]()
        /// if (and only if) it is an arbiter.
        public
        let replica:Replica?

        public
        init(id:Int64, host:Mongo.Host, replica:Replica?)
        {
            self.id = id
            self.host = host
            self.replica = replica
        }
    }
}
extension Mongo.ReplicaSetConfiguration.Member
{
    @frozen public
    enum CodingKeys:String
    {
        case arbiterOnly
        case buildsIndexes = "buildIndexes"
        case hidden
        case host
        case id = "_id"
        case priority
        case secondaryDelaySeconds = "secondaryDelaySecs"
        case tags
        case votes
    }
}
extension Mongo.ReplicaSetConfiguration.Member:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        let id:Int64 = try bson[.id].decode(to: Int64.self)
        let host:Mongo.Host = try bson[.host].decode(to: Mongo.Host.self)

        if  try bson[.arbiterOnly].decode(to: Bool.self)
        {
            self.init(id: id, host: host, replica: nil)
            return
        }

        let rights:Mongo.ReplicaSetConfiguration.Rights

        if  let citizen:Mongo.ReplicaSetConfiguration.Citizen = .init(
                priority: try bson[.priority].decode(to: Double.self))
        {
            rights = .citizen(citizen)
        }
        else
        {
            rights = .resident(.init(
                buildsIndexes: try bson[.buildsIndexes].decode(to: Bool.self),
                delay: try bson[.hidden].decode(to: Bool.self) ?
                    try bson[.secondaryDelaySeconds].decode(to: Seconds.self) : nil))
        }

        self.init(id: id, host: host, replica: .init(rights: rights,
            votes: try bson[.votes].decode(to: Int.self),
            tags: try bson[.tags].decode(to: OrderedDictionary<String, String>.self)))
    }
}
extension Mongo.ReplicaSetConfiguration.Member:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.id] = self.id
        bson[.host] = self.host

        guard let replica:Mongo.ReplicaSetConfiguration.Replica = self.replica
        else
        {
            bson[.arbiterOnly] = true
            return
        }

        switch replica.rights
        {
        case .resident(let resident):
            if  let delay:Seconds = resident.delay
            {
                bson[.secondaryDelaySeconds] = delay
                bson[.hidden] = true
            }
            bson[.buildsIndexes] = resident.buildsIndexes
            bson[.priority] = 0.0
        
        case .citizen(let citizen):
            bson[.priority] = citizen.priority
        }

        bson[.votes] = replica.votes
        bson[.tags, elide: true] = replica.tags
    }
}
