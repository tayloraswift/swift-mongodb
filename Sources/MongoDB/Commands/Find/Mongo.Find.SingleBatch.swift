import BSONDecoding
import BSONEncoding
import Durations
import MongoSchema

extension Mongo.Find
{
    @frozen public
    struct SingleBatch:Sendable where Element:MongoDecodable
    {
        public
        var find:Mongo.Find<Element>

        public
        init(collection:Mongo.Collection,
            limit:Int,
            skip:Int? = nil,
            filter:Mongo.PredicateDocument = [:],
            projection:Mongo.ProjectionDocument = [:],
            hint:Mongo.IndexHint? = nil,
            sort:Mongo.SortDocument = [:],
            `let`:Mongo.LetDocument = [:],
            collation:Mongo.Collation? = nil,
            readConcern:Mongo.ReadConcern? = nil,
            min:BSON.Fields = [:],
            max:BSON.Fields = [:],
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
                readConcern: readConcern,
                min: min,
                max: max,
                returnKey: returnKey,
                showRecordIdentifier: showRecordIdentifier)
            
            self.find.fields["singleBatch"] = true
        }
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
    typealias Response = [Element]

    @inlinable public
    var readConcern:Mongo.ReadConcern?
    {
        self.find.readConcern
    }

    @inlinable public
    var fields:BSON.Fields
    {
        self.find.fields
    }

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
