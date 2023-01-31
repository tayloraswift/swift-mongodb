import BSONEncoding
import Durations
import MongoSchema

extension Mongo
{
    public
    struct Find<Element>:Sendable where Element:MongoDecodable
    {
        public
        let collection:Collection
        public
        let timeout:Milliseconds?
        public
        let tailing:Tailing?
        public
        let stride:Int

        public
        let filter:MongoQuery.Document
        public
        let projection:MongoProjection.Document
        public
        let sort:BSON.Fields
        public
        let `let`:BSON.Fields

        public
        let skip:Int?
        public
        let limit:Int?

        public
        let collation:Collation?
        public
        let readLevel:ReadLevel?

        public
        let hint:IndexHint?
        public
        let min:BSON.Fields
        public
        let max:BSON.Fields
        public
        let returnKey:Bool?
        public
        let showRecordIdentifier:Bool?

        public
        init(collection:Collection,
            tailing:Tailing? = nil,
            stride:Int,
            limit:Int? = nil,
            skip:Int? = nil,
            filter:MongoQuery.Document = .init(),
            projection:MongoProjection.Document = .init(),
            hint:IndexHint? = nil,
            sort:BSON.Fields = .init(),
            `let`:BSON.Fields = .init(),
            collation:Collation? = nil,
            readLevel:ReadLevel? = nil,
            timeout:Milliseconds? = nil,
            min:BSON.Fields = .init(),
            max:BSON.Fields = .init(),
            returnKey:Bool? = nil,
            showRecordIdentifier:Bool? = nil)
        {
            self.collection = collection
            self.timeout = timeout
            self.tailing = tailing
            self.stride = stride
            self.limit = limit
            self.skip = skip
            self.let = `let`
            self.filter = filter
            self.sort = sort
            self.projection = projection
            self.collation = collation
            self.readLevel = readLevel
            self.hint = hint
            self.min = min
            self.max = max
            self.returnKey = returnKey
            self.showRecordIdentifier = showRecordIdentifier
        }
    }
}
extension Mongo.Find
{
    var tailable:Bool
    {
        switch self.tailing
        {
        case _?:        return true
        case nil:       return false
        }
    }
    var awaitData:Bool
    {
        self.tailing?.awaits ?? false
    }
}
extension Mongo.Find:MongoIterableCommand
{
    public
    typealias Response = Mongo.Cursor<Element>
}
extension Mongo.Find:MongoReadCommand
{
}
extension Mongo.Find:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    /// The string [`"find"`]().
    @inlinable public static
    var name:String
    {
        "find"
    }
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = self.collection
        bson["batchSize"] = self.stride
        bson["maxTimeMS"] = self.timeout
        bson["tailable"] = self.tailable ? true : nil
        bson["awaitData"] = self.awaitData ? true : nil
            
        bson["let", elide: true] = self.let
        bson["filter", elide: true] = self.filter
        bson["sort", elide: true] = self.sort
        bson["projection", elide: true] = self.projection
            
        bson["skip"] = self.skip
        bson["limit"] = self.limit

        bson["collation"] = self.collation
            
        bson["hint"] = self.hint
        bson["min", elide: true] = self.min
        bson["max", elide: true] = self.max
            
        bson["returnKey"] = self.returnKey
        bson["showRecordId"] = self.showRecordIdentifier
    }
}
