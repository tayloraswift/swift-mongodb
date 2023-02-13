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
        var fields:BSON.Fields

        private
        init(readConcern:ReadConcern?,
            tailing:Mode.Tailing?,
            stride:Mode.Stride,
            fields:BSON.Fields)
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
        with populate:(inout BSON.Fields) throws -> ()) rethrows
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
    typealias Response = Mode.CommandResponse

    @inlinable public static
    func decode(reply:BSON.Dictionary<ByteBufferView>) throws -> Mode.CommandResponse
    {
        try Mode.decode(reply: reply)
    }
}
extension Mongo.Find:MongoIterableCommand
    where   Response == Mongo.Cursor<Mode.Element>,
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
        self.readConcern = readConcern
        self.tailing = tailing
        self.stride = stride

        self.fields = .init
        {
            $0[Self.name] = collection
            $0["awaitData"] = tailing.flatMap { $0.awaits ? true : nil }
            $0["tailable"] = tailing.map { _ in true }
            $0["batchSize"] = stride
            $0["limit"] = limit
            $0["skip"] = skip
        }
    }
    public
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
        self.readConcern = readConcern
        self.tailing = nil
        self.stride = ()

        self.fields = .init
        {
            $0[Self.name] = collection
            $0["batchSize"] = limit
            $0["limit"] = limit
            $0["skip"] = skip
        }
    }
    public
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
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }
}

extension Mongo.Find
{
    @frozen public
    enum Filter:String, Hashable, Sendable
    {
        case filter
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
    }
}
extension Mongo.Find.Flag
{
    @available(*, unavailable, renamed: "showRecordIdentifier")
    public static
    var showRecordId:Self
    {
        .showRecordIdentifier
    }
}

extension Mongo.Find
{
    @frozen public
    enum Hint:String, Hashable, Sendable
    {
        case hint
    }
}

extension Mongo.Find
{
    @frozen public
    enum Let:String, Hashable, Sendable
    {
        case `let`
    }
}

extension Mongo.Find
{
    @frozen public
    enum Projection:String, Hashable, Sendable
    {
        case projection
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
}

extension Mongo.Find
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort
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
    subscript(key:Range) -> BSON.Fields?
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
