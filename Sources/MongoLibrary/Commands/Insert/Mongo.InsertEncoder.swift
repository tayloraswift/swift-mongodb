import BSON

extension Mongo
{
    @frozen public
    struct InsertEncoder
    {
        @usableFromInline internal
        var output:BSON.Output<[UInt8]>

        @inlinable internal
        init()
        {
            self.output = .init(preallocated: [])
        }
    }
}
extension Mongo.InsertEncoder
{
    @inlinable internal consuming
    func move() -> BSON.Output<[UInt8]> { self.output }
}
extension Mongo.InsertEncoder
{
    @inlinable public static
    func += (self:inout Self, elements:some Sequence<some BSONDocumentEncodable>)
    {
        for element:some BSONDocumentEncodable in elements
        {
            self.append(element)
        }
    }

    @inlinable public mutating
    func append<CodingKey>(_ element:some BSONDocumentEncodable<CodingKey>)
    {
        element.encode(to: &self.output[
            as: BSON.DocumentEncoder<CodingKey>.self,
            in: BSON.DocumentFrame.self])
    }
}
