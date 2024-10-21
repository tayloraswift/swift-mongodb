import BSON

extension Mongo
{
    @frozen public
    struct PredicateListEncoder
    {
        @usableFromInline internal
        var list:BSON.ListEncoder

        @inlinable internal
        init(list:BSON.ListEncoder)
        {
            self.list = list
        }
    }
}
extension Mongo.PredicateListEncoder:BSON.Encoder
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
extension Mongo.PredicateListEncoder
{
    @inlinable public
    subscript<Encodable>(_:(BSON.ListEncoder.Index) -> Void) -> Encodable?
        where Encodable:BSONEncodable
    {
        get { nil }
        set (value) { self.list[+] = value }
    }

    @inlinable public mutating
    func callAsFunction(with encode:(inout Mongo.PredicateEncoder) -> ())
    {
        self.list.append { encode(&$0[as: Mongo.PredicateEncoder.self]) }
    }
}
