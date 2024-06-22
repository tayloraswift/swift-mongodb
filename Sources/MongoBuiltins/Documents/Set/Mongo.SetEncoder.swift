import BSON

extension Mongo
{
    @frozen public
    struct SetEncoder<CodingKey>:Sendable where CodingKey:RawRepresentable<String>
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<CodingKey>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<CodingKey>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.SetEncoder:BSON.Encoder
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
extension Mongo.SetEncoder
{
    @inlinable public
    subscript<Encodable>(path:CodingKey) -> Encodable? where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path])
        }
    }

    @inlinable public
    subscript(path:CodingKey, yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.ExpressionEncoder.self])
        }
    }
}
