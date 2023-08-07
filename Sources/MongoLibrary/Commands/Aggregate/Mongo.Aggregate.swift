import BSONDecoding
import BSONEncoding
import MongoDriver
import MongoQL
import NIOCore

extension Mongo
{
    public
    struct Aggregate<Effect>:Sendable where Effect:MongoReadEffect
    {
        public
        let writeConcern:WriteConcern?
        public
        let readConcern:ReadConcern?
        public
        let stride:Effect.Stride

        public
        var fields:BSON.Document

        public
        init(writeConcern:WriteConcern?,
            readConcern:ReadConcern?,
            stride:Effect.Stride,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.readConcern = readConcern
            self.stride = stride
            self.fields = fields
        }
    }
}
extension Mongo.Aggregate:MongoIterableCommand
    where   Effect.Stride == Int,
            Effect.Batch == Mongo.Cursor<Effect.BatchElement>.Batch
{
    public
    typealias Element = Effect.BatchElement

    @inlinable public
    var tailing:Mongo.Tailing? { nil }
}
extension Mongo.Aggregate:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .aggregate }

    public
    typealias Response = Effect.Batch

    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> Effect.Batch
    {
        try Effect.decode(reply: reply)
    }
}
extension Mongo.Aggregate where Effect.Stride == Int
{
    public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline,
        stride:Int)
    {
        self.init(
            writeConcern: writeConcern,
            readConcern: readConcern,
            stride: stride,
            fields: Self.type(collection))

        self.fields["pipeline"] = pipeline
        self.fields["cursor"]
        {
            $0["batchSize"] = stride
        }
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline,
        stride:Int,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection,
            writeConcern: writeConcern,
            readConcern: readConcern,
            pipeline: pipeline,
            stride: stride)
        try populate(&self)
    }
}
extension Mongo.Aggregate where Effect.Stride == Never?
{
    public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline)
    {
        self.init(
            writeConcern: writeConcern,
            readConcern: readConcern,
            stride: nil,
            fields: Self.type(collection))

        self.fields["pipeline"] = pipeline
        self.fields["cursor"]
        {
            $0["batchSize"] = Int.max
        }
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection,
            writeConcern: writeConcern,
            readConcern: readConcern,
            pipeline: pipeline)
        try populate(&self)
    }
}
extension Mongo.Aggregate<Mongo.ExplainOnly>
{
    public
    init(_ collection:Mongo.Collection, pipeline:Mongo.Pipeline)
    {
        self.init(
            writeConcern: nil,
            readConcern: nil,
            stride: (),
            fields: Self.type(collection))

        self.fields["pipeline"] = pipeline
        self.fields["explain"] = true
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        pipeline:Mongo.Pipeline,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection, pipeline: pipeline)
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
