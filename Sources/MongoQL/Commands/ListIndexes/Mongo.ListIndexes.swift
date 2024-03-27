import BSON

extension Mongo
{
    /// The `listIndexes` command.
    ///
    /// This type is generic because even though we currently only support returning
    /// ``IndexBinding``s, in the future we may have a way to return fully-modeled index
    /// specifications.
    @frozen public
    struct ListIndexes<Element>:Sendable where Element:BSONDecodable & Sendable
    {
        public
        let stride:Int?

        public private(set)
        var fields:BSON.Document

        private
        init(stride:Int?, fields:BSON.Document)
        {
            self.stride = stride
            self.fields = fields
        }
    }
}
extension Mongo.ListIndexes:Mongo.Command
{
    /// `ListIndexes` supports retryable reads.
    public
    typealias ExecutionPolicy = Mongo.Retry

    @inlinable public static
    var type:Mongo.CommandType { .listIndexes }

    public
    typealias Response = Mongo.CursorBatch<Element>
}
extension Mongo.ListIndexes
{
    @frozen @usableFromInline
    enum BuiltinKey:String, Sendable
    {
        case cursor
    }
}
extension Mongo.ListIndexes<Mongo.IndexBinding>
{
    public
    init(_ collection:Mongo.Collection, stride:Int? = nil)
    {
        self.init(stride: stride, fields: Self.type(collection))
        if  let stride:Int
        {
            self.fields[BuiltinKey.self][.cursor] = Mongo.CursorOptions.init(batchSize: stride)
        }
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        stride:Int? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection, stride: stride)
        try populate(&self)
    }
}
