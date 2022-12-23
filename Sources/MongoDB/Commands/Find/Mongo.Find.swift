import BSONEncoding
import Durations
import MongoSchema

extension Mongo
{
    @frozen public
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
        let `let`:BSON.Fields
        public
        let filter:BSON.Fields
        public
        let sort:BSON.Fields
        public
        let projection:BSON.Fields

        public
        let skip:Int
        public
        let limit:Int

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
            timeout:Milliseconds? = nil,
            tailing:Tailing? = nil,
            stride:Int,
            `let`:BSON.Fields = .init(),
            filter:BSON.Fields = .init(),
            sort:BSON.Fields = .init(),
            projection:BSON.Fields = .init(),
            skip:Int = 0,
            limit:Int = 0,
            collation:Collation? = nil,
            readLevel:ReadLevel? = nil,
            hint:IndexHint? = nil,
            min:BSON.Fields = .init(),
            max:BSON.Fields = .init(),
            returnKey:Bool? = nil,
            showRecordIdentifier:Bool? = nil)
        {
            self.collection = collection
            self.timeout = timeout
            self.tailing = tailing
            self.stride = stride
            self.let = `let`
            self.filter = filter
            self.sort = sort
            self.projection = projection
            self.skip = skip
            self.limit = limit
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
    // var batchSize:Int64
    // {
    //     switch self.batching
    //     {
    //     case .batch(of: let size), .batches(of: let size):
    //         return .init(size)
    //     }
    // }
    // var singleBatch:Bool
    // {
    //     switch self.batching
    //     {
    //     case .batch:    return true
    //     case .batches:  return false
    //     }
    // }
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
        switch self.tailing
        {
        case .await:    return true
        default:        return false
        }
    }
}
extension Mongo.Find:MongoCommand
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["find"] = self.collection
        bson["batchSize"] = self.stride
        // bson["singleBatch"] = self.singleBatch ? true : nil
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

    public
    typealias Response = Mongo.Cursor<Element>
}
extension Mongo.Find:MongoDatabaseCommand
{
}
extension Mongo.Find:MongoReadCommand, MongoImplicitSessionCommand
{
}
extension Mongo.Find:MongoStreamableCommand
{
}
extension Mongo.Find:MongoTransactableCommand
{
}
