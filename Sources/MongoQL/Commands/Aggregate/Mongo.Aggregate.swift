import BSON

extension Mongo
{
    @frozen public
    struct Aggregate<Effect>:Sendable where Effect:Mongo.ReadEffect
    {
        public
        let writeConcern:WriteConcern?
        public
        let readConcern:ReadConcern?
        public
        let tailing:Effect.Tailing?
        public
        let stride:Effect.Stride?

        public
        var fields:BSON.Document

        @inlinable
        init(writeConcern:WriteConcern?,
            readConcern:ReadConcern?,
            tailing:Effect.Tailing?,
            stride:Effect.Stride?,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.readConcern = readConcern
            self.tailing = tailing
            self.stride = stride
            self.fields = fields
        }
    }
}
extension Mongo.Aggregate:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .aggregate }

    public
    typealias Response = Effect.Batch

    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key>) throws -> Effect.Batch
    {
        try Effect.decode(reply: reply)
    }
}
extension Mongo.Aggregate
{
    @frozen @usableFromInline
    enum BuiltinKey:String, Sendable
    {
        case pipeline
        case explain

        case cursor
    }
}
extension Mongo.Aggregate
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        tailing:Effect.Tailing? = nil,
        stride:Effect.Stride? = nil,
        pipeline:(inout Mongo.PipelineEncoder) throws -> ()) rethrows
    {
        self.init(
            writeConcern: writeConcern,
            readConcern: readConcern,
            tailing: tailing,
            stride: stride,
            fields: Self.type(collection))
        try
        {
            if  let stride:Effect.Stride = stride
            {
                $0[.cursor] = Mongo.CursorOptions<Effect.Stride>.init(batchSize: stride)
            }
            else
            {
                $0[.cursor] = Mongo.CursorOptions<Int>.init(batchSize: .max)
            }

            try pipeline(&$0[.pipeline][as: Mongo.PipelineEncoder.self])

        } (&self.fields[BuiltinKey.self])
    }

    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        tailing:Effect.Tailing? = nil,
        stride:Effect.Stride? = nil,
        pipeline:(inout Mongo.PipelineEncoder) throws -> (),
        options configure:(inout Self) throws -> ()) rethrows
    {
        try self.init(collection,
            writeConcern: writeConcern,
            readConcern: readConcern,
            tailing: tailing,
            stride: stride,
            pipeline: pipeline)
        try configure(&self)
    }
}
extension Mongo.Aggregate<Mongo.ExplainOnly>
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        pipeline:(inout Mongo.PipelineEncoder) throws -> ()) rethrows
    {
        self.init(
            writeConcern: nil,
            readConcern: nil,
            tailing: nil,
            stride: nil,
            fields: Self.type(collection))

        try
        {
            try pipeline(&$0[.pipeline][as: Mongo.PipelineEncoder.self])

            $0[.explain] = true

        } (&self.fields[BuiltinKey.self])
    }

    @inlinable public
    init(_ collection:Mongo.Collection,
        pipeline:(inout Mongo.PipelineEncoder) throws -> (),
        options configure:(inout Self) throws -> ()) rethrows
    {
        try self.init(collection, pipeline: pipeline)
        try configure(&self)
    }
}

extension Mongo.Aggregate
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }

    @inlinable public
    subscript(key:Collation) -> Mongo.Collation?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.Aggregate
{
    @frozen public
    enum Flag:String, Hashable, Sendable
    {
        case allowDiskUse
        case bypassDocumentValidation
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
            value?.encode(to: &self.fields[with: key])
        }
    }
}
extension Mongo.Aggregate
{
    @frozen public
    enum Hint:String, Hashable, Sendable
    {
        case hint
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
            value?.encode(to: &self.fields[with: key])
        }
    }

    @inlinable public
    subscript(key:Hint, yield:(inout Mongo.SortEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.SortEncoder.self])
        }
    }
}
extension Mongo.Aggregate
{
    @frozen public
    enum Let:String, Sendable
    {
        case `let`
    }

    @inlinable public
    subscript(key:Let, yield:(inout Mongo.LetEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.LetEncoder.self])
        }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(key:Let) -> Mongo.LetDocument?
    {
        nil
    }
}
