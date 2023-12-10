import BSON

//  This must be an extension on ``Optional`` and not ``BSONEncodable``
//  because SE-299 does not support protocol extension member lookup with
//  unnamed closure parameters.
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
