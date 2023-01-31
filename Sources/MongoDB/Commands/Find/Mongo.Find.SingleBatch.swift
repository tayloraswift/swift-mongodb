import BSONSchema
import Durations
import MongoSchema

extension Mongo.Find
{
    @frozen public
    struct SingleBatch:Sendable where Element:MongoDecodable
    {
        public
        let find:Mongo.Find<Element>

        public
        init(collection:Mongo.Collection,
            limit:Int,
            skip:Int? = nil,
            filter:MongoQuery.Document = .init(),
            projection:MongoProjection.Document = .init(),
            hint:Mongo.IndexHint? = nil,
            sort:BSON.Fields = .init(),
            `let`:BSON.Fields = .init(),
            collation:Mongo.Collation? = nil,
            readLevel:Mongo.ReadLevel? = nil,
            timeout:Milliseconds? = nil,
            min:BSON.Fields = .init(),
            max:BSON.Fields = .init(),
            returnKey:Bool? = nil,
            showRecordIdentifier:Bool? = nil)
        {
            self.find = .init(
                collection: collection,
                tailing: nil,
                stride: limit,
                limit: nil,
                skip: skip,
                filter: filter,
                projection: projection,
                hint: hint,
                sort: sort,
                let: `let`,
                collation: collation,
                readLevel: readLevel,
                timeout: timeout,
                min: min,
                max: max,
                returnKey: returnKey,
                showRecordIdentifier: showRecordIdentifier)
        }
    }
}
extension Mongo.Find.SingleBatch:MongoReadCommand
{
    @inlinable public
    var readLevel:Mongo.ReadLevel?
    {
        self.find.readLevel
    }
}
extension Mongo.Find.SingleBatch:MongoImplicitSessionCommand,
    MongoTransactableCommand,
    MongoCommand
{
    /// The string [`"find"`]().
    @inlinable public static
    var name:String
    {
        Mongo.Find<Element>.name
    }

    public
    func encode(to bson:inout BSON.Fields)
    {
        self.find.encode(to: &bson)
        bson["singleBatch"] = true
    }

    public
    typealias Response = [Element]

    @inlinable public static
    func decode<Bytes>(reply:BSON.Dictionary<Bytes>) throws -> [Element]
    {
        try reply["cursor"].decode(as: BSON.Dictionary<Bytes.SubSequence>.self)
        {
            if  let cursor:Mongo.CursorIdentifier = .init(
                    rawValue: try $0["id"].decode(to: Int64.self))
            {
                throw Mongo.CursorIdentifierError.init(invalid: cursor)
            }
            else
            {
                return try $0["firstBatch"].decode(to: [Element].self)
            }
        }
    }
}
