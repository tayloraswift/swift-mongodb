import BSONDecoding
import BSONEncoding
import NIOCore

extension Mongo
{
    public
    struct Aggregate<Mode>:Sendable where Mode:MongoBatchingMode
    {
        public
        let writeConcern:WriteConcern?
        public
        let readConcern:ReadConcern?
        public
        let stride:Mode.Stride

        public
        var fields:BSON.Document

        public
        init(writeConcern:WriteConcern?,
            readConcern:ReadConcern?,
            stride:Mode.Stride,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.readConcern = readConcern
            self.stride = stride
            self.fields = fields
        }
    }
}
extension Mongo.Aggregate
{
    private
    init(writeConcern:WriteConcern?,
        readConcern:ReadConcern?,
        stride:Mode.Stride,
        with populate:(inout BSON.Document) throws -> ()) rethrows
    {
        self.init(writeConcern: writeConcern,
            readConcern: readConcern,
            stride: stride,
            fields: try .init(with: populate))
    }
}

extension Mongo.Aggregate:MongoIterableCommand
    where   Mode.Response == Mongo.Cursor<Mode.Element>,
            Mode.Stride == Int
{
    public
    typealias Element = Mode.Element
    
    @inlinable public
    var tailing:Mongo.Tailing?
    {
        nil
    }
}
extension Mongo.Aggregate:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    /// The string [`"aggregate"`]().
    @inlinable public static
    var name:String
    {
        "aggregate"
    }

    public
    typealias Response = Mode.Response

    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<String, ByteBufferView>) throws -> Mode.Response
    {
        try Mode.decode(reply: reply)
    }
}

extension Mongo.Aggregate where Mode.Stride == Int
{
    public
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline,
        stride:Int)
    {
        self.init(writeConcern: writeConcern, readConcern: readConcern, stride: stride)
        {
            $0[Self.name] = collection
            
            $0["pipeline", elide: false] = pipeline
            $0["cursor"] = .init
            {
                $0["batchSize"] = stride
            }
        }
    }
    @inlinable public
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline,
        stride:Int,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection: collection,
            writeConcern: writeConcern,
            readConcern: readConcern,
            pipeline: pipeline,
            stride: stride)
        try populate(&self)
    }
}

extension Mongo.Aggregate where Mode.Stride == Void, Mode.Element == Never
{
    public
    init(collection:Mongo.Collection, pipeline:Mongo.Pipeline)
    {
        self.init(writeConcern: nil, readConcern: nil, stride: ())
        {
            $0[Self.name] = collection
            
            $0["pipeline", elide: false] = pipeline
            $0["explain"] = true
        }
    }
    @inlinable public
    init(collection:Mongo.Collection,
        pipeline:Mongo.Pipeline,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection: collection, pipeline: pipeline)
        try populate(&self)
    }
}

extension Mongo.Aggregate
{
    @inlinable public
    subscript(key:Collation) -> Mongo.Collation?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields.push(key, value)
        }
    }

    @inlinable public
    subscript(key:Flag) -> Bool?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields.push(key, value)
        }
    }

    @inlinable public
    subscript(key:Hint) -> String?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields.push(key, value)
        }
    }
    @inlinable public
    subscript(key:Hint) -> Mongo.SortDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields.push(key, value)
        }
    }

    @inlinable public
    subscript(key:Let) -> Mongo.LetDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields.push(key, value)
        }
    }
}
