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
        var fields:BSON.Fields

        public
        let writeConcern:WriteConcern?
        public
        let readConcern:ReadConcern?
        public
        let stride:Int

        public
        init(collection:Collection,
            _cursor:CursorOptions,
            pipeline:Pipeline,
            hint:IndexHint? = nil,
            `let`:LetDocument,
            collation:Collation? = nil,
            writeConcern:WriteConcern? = nil,
            readConcern:ReadConcern? = nil)
        {
            self.writeConcern = writeConcern
            self.readConcern = readConcern
            self.stride = _cursor.stride
            self.fields = .init
            {
                $0[Self.name] = collection
                
                $0["cursor"] = _cursor
                //$0["maxTimeMS"] = self.timeout

                $0["pipeline", elide: false] = pipeline
                $0["hint"] = hint
                $0["let", elide: true] = `let`
                    
                $0["collation"] = collation
            }
        }
    }
}
extension Mongo.Aggregate:MongoReadCommand, MongoWriteCommand
    where Element:MongoDecodable
{
}
extension Mongo.Aggregate:MongoIterableCommand
    where Element:MongoDecodable
{
    public
    typealias Response = Mongo.Cursor<Element>

    @inlinable public
    var tailing:Mongo.Tailing?
    {
        nil
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
