import BSONEncoding

extension BSON.List<MongoExpression>:MongoExpressionEncodable
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
extension BSON.List<MongoExpression>?
{
    @_disfavoredOverload
    @inlinable public
    init(with populate:(inout Wrapped) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
