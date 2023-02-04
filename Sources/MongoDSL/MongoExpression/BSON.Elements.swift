import BSONEncoding

extension BSON.Elements<MongoExpressionDSL>:MongoExpressionEncodable
{
    @inlinable public mutating
    func push(_ element:(some MongoExpressionEncodable)?)
    {
        element.map
        {
            self.append($0)
        }
    }
}
extension BSON.Elements<MongoExpressionDSL>?
{
    @_disfavoredOverload
    @inlinable public
    init(with populate:(inout BSON.Elements<MongoExpressionDSL>) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
