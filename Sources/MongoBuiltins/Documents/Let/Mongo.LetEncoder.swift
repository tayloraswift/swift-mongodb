import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct LetEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<BSON.Key>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.LetEncoder:BSON.Encoder
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
extension Mongo.LetEncoder
{
    @inlinable public
    subscript(`let` binding:Mongo.Variable<some Any>,
        yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: binding.name][as: Mongo.ExpressionEncoder.self])
        }
    }

    @inlinable public
    subscript<Encodable>(`let` binding:Mongo.Variable<some Any>) -> Encodable?
        where Encodable:BSONEncodable
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: binding.name])
        }
    }
}
