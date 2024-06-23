import BSON

extension Mongo
{
    @frozen public
    struct Find<Effect>:Sendable where Effect:Mongo.ReadEffect
    {
        public
        let readConcern:ReadConcern?
        public
        let tailing:Effect.Tailing?
        public
        let stride:Effect.Stride?

        public
        var fields:BSON.Document

        @inlinable
        init(readConcern:ReadConcern?,
            tailing:Effect.Tailing?,
            stride:Effect.Stride?,
            fields:BSON.Document)
        {
            self.readConcern = readConcern
            self.tailing = tailing
            self.stride = stride
            self.fields = fields
        }
    }
}
extension Mongo.Find:Mongo.Command
{
    /// The string [`"find"`]().
    @inlinable public static
    var type:Mongo.CommandType { .find }

    /// `Find` supports retryable reads.
    public
    typealias ExecutionPolicy = Mongo.Retry

    public
    typealias Response = Effect.Batch

    @inlinable public static
    func decode(reply:BSON.DocumentDecoder<BSON.Key>) throws -> Effect.Batch
    {
        try Effect.decode(reply: reply)
    }
}
extension Mongo.Find where Effect.Tailing == Mongo.Tailing, Effect.Stride == Int
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        readConcern:ReadConcern? = nil,
        tailing:Mongo.Tailing? = nil,
        stride:Int,
        limit:Int? = nil,
        skip:Int? = nil)
    {
        self.init(readConcern: readConcern,
            tailing: tailing,
            stride: stride,
            fields: Self.type(collection))
        ;
        {
            $0["awaitData"] = tailing.flatMap { $0.awaits ? true : nil }
            $0["tailable"] = tailing.map { _ in true }
            $0["batchSize"] = stride
            $0["limit"] = limit
            $0["skip"] = skip
        } (&self.fields[BSON.Key.self])
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        readConcern:ReadConcern? = nil,
        tailing:Mongo.Tailing? = nil,
        stride:Int,
        limit:Int? = nil,
        skip:Int? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection,
            readConcern: readConcern,
            tailing: tailing,
            stride: stride,
            limit: limit,
            skip: skip)
        try populate(&self)
    }
}
extension Mongo.Find where Effect.Tailing == Never, Effect.Stride == Never
{
    public
    init(_ collection:Mongo.Collection,
        readConcern:ReadConcern? = nil,
        limit:Int,
        skip:Int? = nil)
    {
        self.init(readConcern: readConcern,
            tailing: nil,
            stride: nil,
            fields: Self.type(collection))
        ;
        {
            $0["singleBatch"] = true
            $0["batchSize"] = limit
            $0["limit"] = limit
            $0["skip"] = skip
        } (&self.fields[BSON.Key.self])
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        readConcern:ReadConcern? = nil,
        limit:Int,
        skip:Int? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection,
            readConcern: readConcern,
            limit: limit,
            skip: skip)
        try populate(&self)
    }
}

extension Mongo.Find
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
extension Mongo.Find
{
    @frozen public
    enum Filter:String, Hashable, Sendable
    {
        case filter
    }

    @inlinable public
    subscript(key:Filter, yield:(inout Mongo.PredicateEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.PredicateEncoder.self])
        }
    }
}
extension Mongo.Find
{
    @frozen public
    enum Flag:String, Hashable, Sendable
    {
        case allowDiskUse
        case allowPartialResults
        case noCursorTimeout
        case returnKey
        case showRecordIdentifier = "showRecordId"

        @available(*, unavailable, renamed: "showRecordIdentifier")
        public static
        var showRecordId:Self
        {
            .showRecordIdentifier
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
}
extension Mongo.Find
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
extension Mongo.Find
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
extension Mongo.Find
{
    @frozen public
    enum Projection:String, Hashable, Sendable
    {
        case projection
    }

    /// Encodes a projection document.
    @inlinable public
    subscript(key:Projection, yield:(inout Mongo.ProjectionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.ProjectionEncoder.self])
        }
    }

    /// Encodes a projection document from a model type.
    @inlinable public
    subscript<ProjectionDocument>(key:Projection) -> ProjectionDocument?
        where ProjectionDocument:Mongo.ProjectionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.fields[with: key][as: Mongo.ProjectionEncoder.self])
        }
    }
}
extension Mongo.Find
{
    @frozen public
    enum Range:String, Hashable, Sendable
    {
        case max
        case min
    }

    @inlinable public
    subscript(key:Range) -> BSON.Document?
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
extension Mongo.Find
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort
    }

    @inlinable public
    subscript(key:Sort, yield:(inout Mongo.SortEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.SortEncoder.self])
        }
    }
}
