import BSON

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
    /// >   See:
    /// https://www.mongodb.com/docs/manual/reference/command/listCollections/
    ///
    /// >   See:
    /// https://github.com/mongodb/specifications/blob/master/source/enumerate-collections.rst
    public
    struct ListCollections<Element>:Sendable where Element:BSONDecodable & Sendable
    {
        public
        let stride:Int?

        public
        var fields:BSON.Document

        private
        init(stride:Int, fields:BSON.Document)
        {
            self.stride = stride
            self.fields = fields
        }
    }
}
extension Mongo.ListCollections:Mongo.Command
{
    /// `ListCollections` supports retryable reads.
    public
    typealias ExecutionPolicy = Mongo.Retry

    @inlinable public static
    var type:Mongo.CommandType { .listCollections }

    public
    typealias Response = Mongo.CursorBatch<Element>
}
extension Mongo.ListCollections
{
    @frozen @usableFromInline
    enum BuiltinKey:String, Sendable
    {
        case nameOnly
        case cursor
    }
}
extension Mongo.ListCollections<Mongo.CollectionBinding>
{
    public
    init(stride:Int)
    {
        self.init(stride: stride, fields: Self.type(1))
        ;
        {
            $0[.cursor] = Mongo.CursorOptions.init(batchSize: stride)
            $0[.nameOnly] = true
        } (&self.fields[BuiltinKey.self])
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
        self.init(stride: stride, fields: Self.type(1))
        self.fields[BuiltinKey.self][.cursor] = Mongo.CursorOptions.init(batchSize: stride)
    }
    @inlinable public
    init(stride:Int, with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(stride: stride)
        try populate(&self)
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
            value?.encode(to: &self.fields[with: key])
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
            value?.encode(to: &self.fields[with: key])
        }
    }
}
