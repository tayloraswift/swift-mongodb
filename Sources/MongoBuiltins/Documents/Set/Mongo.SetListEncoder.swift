import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct SetListEncoder:Sendable
    {
        @usableFromInline
        var list:BSON.ListEncoder

        @inlinable
        init(list:BSON.ListEncoder)
        {
            self.list = list
        }
    }
}
extension Mongo.SetListEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(list: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.list.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .list }
}
extension Mongo.SetListEncoder
{
    @inlinable public
    subscript<Encodable>(_:(BSON.ListEncoder.Index) -> Void) -> Encodable?
        where Encodable:BSONEncodable
    {
        get { nil }
        set (value) { self.list[+] = value }
    }

    @inlinable public mutating
    func callAsFunction(
        _ yield:(inout Mongo.ExpressionEncoder) -> ())
    {
        yield(&self.list[+][as: Mongo.ExpressionEncoder.self])
    }

    @inlinable public mutating
    func callAsFunction(_:Int.Type = Int.self,
        _ yield:(inout Mongo.SetListEncoder) -> ())
    {
        yield(&self.list[+][as: Mongo.SetListEncoder.self])
    }

    @inlinable public mutating
    func callAsFunction<CodingKey>(_:CodingKey.Type,
        _ yield:(inout Mongo.SetEncoder<CodingKey>) -> ())
    {
        yield(&self.list[+][as: Mongo.SetEncoder<CodingKey>.self])
    }
}
