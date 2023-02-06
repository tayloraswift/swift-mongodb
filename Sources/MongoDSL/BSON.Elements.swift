import BSONEncoding

extension BSON.Elements<MongoExpression>:MongoExpressionEncodable
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
extension BSON.Elements<MongoExpression>?
{
    @_disfavoredOverload
    @inlinable public
    init(with populate:(inout Wrapped) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
