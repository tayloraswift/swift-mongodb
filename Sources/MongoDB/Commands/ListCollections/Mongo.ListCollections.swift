import BSONDecoding
import BSONEncoding

extension Mongo
{
    /// Retrieves information about collections (including collection-views) in a
    /// database.
    ///
    /// `ListCollections` can return either collection names only (``CollectionBinding``)
    /// or full collection metadata (``CollectionMetadata``). The name-only mode
    /// requires less synchronization on the server-side.
    ///
    /// `ListCollections` has no single-batch mode, it only supports cursor iteration.
    ///
    /// `ListCollections` only supports filtering, it does not support sorting or
    /// projection.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/listCollections/
    ///
    /// > See:  https://github.com/mongodb/specifications/blob/master/source/enumerate-collections.rst
    public
    struct ListCollections<Element>:Sendable where Element:BSONDocumentDecodable & Sendable
    {
        public
        let stride:Int

        public
        var fields:BSON.Fields

        private
        init(stride:Int, fields:BSON.Fields)
        {
            self.stride = stride
            self.fields = fields
        }
    }
}
extension Mongo.ListCollections
{
    private
    init(stride:Int, with populate:(inout BSON.Fields) throws -> ()) rethrows
    {
        self.init(stride: stride, fields: try .init(with: populate))
    }
}
extension Mongo.ListCollections<Mongo.CollectionBinding>
{
    public
    init(stride:Int)
    {
        self.init(stride: stride)
        {
            $0[Self.name] = 1 as Int32
            $0["cursor"] = .init
            {
                $0["batchSize"] = stride
            }
            $0["nameOnly"] = true
        }
    }
    @inlinable public
    init(stride:Int, with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(stride: stride)
        try populate(&self)
    }
}
extension Mongo.ListCollections<Mongo.CollectionMetadata>
{
    public
    init(stride:Int)
    {
        self.init(stride: stride)
        {
            $0[Self.name] = 1 as Int32
            $0["cursor"] = .init
            {
                $0["batchSize"] = stride
            }
        }
    }
    @inlinable public
    init(stride:Int, with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(stride: stride)
        try populate(&self)
    }
}
extension Mongo.ListCollections:MongoIterableCommand
{
    public
    typealias Response = Mongo.Cursor<Element>
    
    @inlinable public
    var tailing:Mongo.Tailing?
    {
        nil
    }
}
extension Mongo.ListCollections:MongoImplicitSessionCommand,
    MongoTransactableCommand,
    MongoCommand
{
    /// The string [`"listCollections"`]().
    @inlinable public static
    var name:String
    {
        "listCollections"
    }
}
// FIXME: ListCollections *can* run on a secondary,
// but *should* run on a primary.

extension Mongo.ListCollections
{
    @inlinable public
    subscript(key:AuthorizedCollections) -> Bool?
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
}
