import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct BucketEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable
        init(bson:BSON.DocumentEncoder<BSON.Key>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.BucketEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}
extension Mongo.BucketEncoder
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case boundaries
        case `default`
    }

    @inlinable public
    subscript<Encodable>(key:Argument) -> Encodable? where Encodable:BSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.BucketEncoder
{
    @inlinable public
    subscript(key:Mongo.GroupBy, yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.ExpressionEncoder.self])
        }
    }

    @inlinable public
    subscript<Encodable>(key:Mongo.GroupBy) -> Encodable? where Encodable:BSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.BucketEncoder
{
    @frozen public
    enum Output:String, Hashable, Sendable
    {
        case output
    }

    @inlinable public
    subscript(key:Output) -> Mongo.BucketOutputDocument?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
