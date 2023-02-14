import BSONDecoding
import BSONEncoding
import Durations
import NIOCore

extension Mongo
{
    public
    struct Find<Mode>:Sendable where Mode:MongoBatchingMode
    {
        public
        let readConcern:ReadConcern?
        public
        let tailing:Mode.Tailing?
        public
        let stride:Mode.Stride

        public
        var fields:BSON.Document

        private
        init(readConcern:ReadConcern?,
            tailing:Mode.Tailing?,
            stride:Mode.Stride,
            fields:BSON.Document)
        {
            self.readConcern = readConcern
            self.tailing = tailing
            self.stride = stride
            self.fields = fields
        }
    }
}
extension Mongo.Find
{
    private
    init(readConcern:ReadConcern?,
        tailing:Mode.Tailing?,
        stride:Mode.Stride,
        with populate:(inout BSON.Document) throws -> ()) rethrows
    {
        self.init(readConcern: readConcern,
            tailing: tailing,
            stride: stride,
            fields: try .init(with: populate))
    }
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
    typealias Response = Mode.Response

    @inlinable public static
    func decode(reply:BSON.Dictionary<ByteBufferView>) throws -> Mode.Response
    {
        try Mode.decode(reply: reply)
    }
}
extension Mongo.Find:MongoIterableCommand
    where   Mode.Response == Mongo.Cursor<Mode.Element>,
            Mode.Tailing == Mongo.Tailing,
            Mode.Stride == Int
{
    public
    typealias Element = Mode.Element
}
extension Mongo.Find where Mode.Tailing == Mongo.Tailing, Mode.Stride == Int
{
    public
    init(collection:Mongo.Collection,
        readConcern:ReadConcern? = nil,
        tailing:Mongo.Tailing? = nil,
        stride:Int,
        limit:Int? = nil,
        skip:Int? = nil)
    {
        self.init(readConcern: readConcern, tailing: tailing, stride: stride)
        {
            $0[Self.name] = collection
            $0["awaitData"] = tailing.flatMap { $0.awaits ? true : nil }
            $0["tailable"] = tailing.map { _ in true }
            $0["batchSize"] = stride
            $0["limit"] = limit
            $0["skip"] = skip
        }
    }
    @inlinable public
    init(collection:Mongo.Collection,
        readConcern:ReadConcern? = nil,
        tailing:Mongo.Tailing? = nil,
        stride:Int,
        limit:Int? = nil,
        skip:Int? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection: collection,
            readConcern: readConcern,
            tailing: tailing,
            stride: stride,
            limit: limit,
            skip: skip)
        try populate(&self)
    }
}
extension Mongo.Find where Mode.Tailing == Never, Mode.Stride == Void
{
    public
    init(collection:Mongo.Collection,
        readConcern:ReadConcern? = nil,
        limit:Int,
        skip:Int? = nil)
    {
        self.init(readConcern: readConcern, tailing: nil, stride: ())
        {
            $0[Self.name] = collection
            $0["singleBatch"] = true
            $0["batchSize"] = limit
            $0["limit"] = limit
            $0["skip"] = skip
        }
    }
    @inlinable public
    init(collection:Mongo.Collection,
        readConcern:ReadConcern? = nil,
        limit:Int,
        skip:Int? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection: collection,
            readConcern: readConcern,
            limit: limit,
            skip: skip)
        try populate(&self)
    }
}

extension Mongo.Find
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
            self.fields[key.rawValue] = value
        }
    }

    @inlinable public
    subscript(key:Filter) -> Mongo.PredicateDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key.rawValue] = value
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
            self.fields[key.rawValue] = value
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
            self.fields[key.rawValue] = value
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
            self.fields[key.rawValue] = value
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
            self.fields[key.rawValue] = value
        }
    }

    @inlinable public
    subscript(key:Projection) -> Mongo.ProjectionDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key.rawValue] = value
        }
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
            self.fields[key.rawValue] = value
        }
    }

    @inlinable public
    subscript(key:Sort) -> Mongo.SortDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key.rawValue] = value
        }
    }
}
