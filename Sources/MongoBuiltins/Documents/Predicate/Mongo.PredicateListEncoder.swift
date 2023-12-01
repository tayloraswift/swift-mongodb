import BSONEncoding

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
extension Mongo.PredicateListEncoder:BSONEncoder
{
    @inlinable public
    init(_ output:consuming BSON.Output<[UInt8]>)
    {
        self.init(list: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output<[UInt8]> { self.list.move() }

    @inlinable public static
    var type:BSON.AnyType { .list }
}
extension Mongo.PredicateListEncoder
{
    @inlinable public mutating
    func append(_ predicate:Mongo.PredicateDocument)
    {
        self.list.append(predicate)
    }
    @inlinable public mutating
    func append(with encode:(inout Mongo.PredicateDocument) -> ())
    {
        self.append(.init(with: encode))
    }
}
