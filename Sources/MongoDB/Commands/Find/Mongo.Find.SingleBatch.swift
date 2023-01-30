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
            timeout:Milliseconds? = nil,
            limit:Int,
            skip:Int? = nil,
            `let`:BSON.Fields = .init(),
            filter:MongoQuery.Document = .init(),
            projection:MongoProjection.Document = .init(),
            sort:BSON.Fields = .init(),
            collation:Mongo.Collation? = nil,
            readLevel:Mongo.ReadLevel? = nil,
            hint:Mongo.IndexHint? = nil,
            min:BSON.Fields = .init(),
            max:BSON.Fields = .init(),
            returnKey:Bool? = nil,
            showRecordIdentifier:Bool? = nil)
        {
            self.find = .init(
                collection: collection,
                timeout: timeout,
                tailing: nil,
                stride: limit,
                limit: nil,
                skip: skip,
                let: `let`,
                filter: filter,
                projection: projection,
                sort: sort,
                collation: collation,
                readLevel: readLevel,
                hint: hint,
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
