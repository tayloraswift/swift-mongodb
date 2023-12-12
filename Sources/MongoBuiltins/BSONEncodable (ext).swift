import BSON

extension BSONEncodable where Self == Mongo.Expression
{
    @inlinable public static
    func expr(with populate:(inout Self) throws -> ()) rethrows -> Self
    {
        var expr:Self = .init(.init())
        try populate(&expr)
        return expr
    }
}
