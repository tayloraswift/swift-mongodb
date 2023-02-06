import BSONEncoding
import Durations
import MongoSchema

extension Mongo
{
    public
    enum CursorOptions:Sendable
    {
        case batches(of:Int)
        case batch(of:Int)
    }
}
extension Mongo.CursorOptions
{
    var stride:Int
    {
        switch self
        {
        case .batch(of: let stride):
            return stride
        case .batches(of: let stride):
            return stride
        }
    }
}
extension Mongo.CursorOptions:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        switch self
        {
        case .batch(of: let stride):
            bson["singleBatch"] = true
            fallthrough
        
        case .batches(of: let stride):
            bson["batchSize"] = stride
        }
    }
}
extension Mongo
{
    public
    struct Aggregate<Element>:Sendable
    {
        public
        let collection:Collection
        public
        let timeout:Milliseconds?

        let cursor:CursorOptions

        public
        let pipeline:Pipeline
        public
        let hint:IndexHint?
        public
        let `let`:LetDocument

        public
        let collation:Collation?
        public
        let readLevel:ReadLevel?

        public
        init(collection:Collection,
            _cursor:CursorOptions,
            pipeline:Pipeline,
            hint:IndexHint? = nil,
            `let`:LetDocument,
            collation:Collation? = nil,
            readLevel:ReadLevel? = nil,
            timeout:Milliseconds? = nil)
        {
            self.collection = collection
            self.timeout = timeout
            self.cursor = _cursor
            self.pipeline = pipeline
            self.hint = hint
            self.let = `let`
            self.collation = collation
            self.readLevel = readLevel
        }
    }
}
extension Mongo.Aggregate:MongoIterableCommand where Element:MongoDecodable
{
    public
    typealias Response = Mongo.Cursor<Element>

    @inlinable public
    var tailing:Mongo.Tailing?
    {
        nil
    }
    public
    var stride:Int
    {
        self.cursor.stride
    }
}
extension Mongo.Aggregate:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
    where Element:MongoDecodable
{
}
extension Mongo.Aggregate
{
    /// The string [`"aggregate"`]().
    @inlinable public static
    var name:String
    {
        "aggregate"
    }
}
extension Mongo.Aggregate:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = self.collection
        
        bson["cursor"] = self.cursor
        bson["maxTimeMS"] = self.timeout

        bson["pipeline", elide: false] = self.pipeline
        bson["hint"] = self.hint
        bson["let", elide: true] = self.let
            
        bson["collation"] = self.collation
    }
}
