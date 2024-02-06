import BSON

extension Mongo
{
    @available(*, deprecated, renamed: "InsertStatementListEncoder")
    public
    typealias InsertEncoder = InsertStatementListEncoder

    @frozen public
    struct InsertStatementListEncoder
    {
        @usableFromInline internal
        var output:BSON.Output

        @inlinable internal
        init()
        {
            self.output = .init(preallocated: [])
        }
    }
}
extension Mongo.InsertStatementListEncoder
{
    @inlinable internal consuming
    func move() -> BSON.Output { self.output }
}
extension Mongo.InsertStatementListEncoder
{
    @inlinable public static
    func += (self:inout Self, elements:some Sequence<some BSONDocumentEncodable>)
    {
        for element:some BSONDocumentEncodable in elements
        {
            self.append(element)
        }
    }

    @inlinable public
    subscript<CodingKey>(_:CodingKey.Type,
        yield:(inout BSON.DocumentEncoder<CodingKey>) -> ()) -> Void
    {
        mutating
        get
        {
            yield(&self.output[
                as: BSON.DocumentEncoder<CodingKey>.self,
                in: BSON.DocumentFrame.self])
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
