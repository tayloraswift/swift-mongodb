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
        let stride:Effect.Stride?

        public
        var fields:BSON.Document

        @inlinable internal
        init(writeConcern:WriteConcern?,
            readConcern:ReadConcern?,
            stride:Effect.Stride?,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.readConcern = readConcern
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
    func decode(reply:BSON.DocumentDecoder<BSON.Key, ArraySlice<UInt8>>) throws -> Effect.Batch
    {
        try Effect.decode(reply: reply)
    }
}
extension Mongo.Aggregate
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline,
        stride:Effect.Stride?)
    {
        self.init(
            writeConcern: writeConcern,
            readConcern: readConcern,
            stride: stride,
            fields: Self.type(collection))
        ;
        {
            $0["pipeline"] = pipeline
            $0["cursor"]
            {
                if  let stride:Effect.Stride = stride
                {
                    $0["batchSize"] = stride
                }
                else
                {
                    $0["batchSize"] = Int.max
                }
            }
        } (&self.fields[BSON.Key.self])
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline,
        stride:Effect.Stride?,
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
extension Mongo.Aggregate where Effect.Stride == Never
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline)
    {
        self.init(collection,
            writeConcern: writeConcern,
            readConcern: readConcern,
            pipeline: pipeline,
            stride: nil)
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        readConcern:ReadConcern? = nil,
        pipeline:Mongo.Pipeline,
        with populate:(inout Self) throws -> ()) rethrows
    {
        try self.init(collection,
            writeConcern: writeConcern,
            readConcern: readConcern,
            pipeline: pipeline,
            stride: nil,
            with: populate)
    }
}
extension Mongo.Aggregate<Mongo.ExplainOnly>
{
    @inlinable public
    init(_ collection:Mongo.Collection, pipeline:Mongo.Pipeline)
    {
        self.init(
            writeConcern: nil,
            readConcern: nil,
            stride: nil,
            fields: Self.type(collection))
        ;
        {
            $0["pipeline"] = pipeline
            $0["explain"] = true
        } (&self.fields[BSON.Key.self])
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
            value?.encode(to: &self.fields[with: key])
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
            value?.encode(to: &self.fields[with: key])
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
            value?.encode(to: &self.fields[with: key])
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
            value?.encode(to: &self.fields[with: key])
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
            value?.encode(to: &self.fields[with: key])
        }
    }
}
