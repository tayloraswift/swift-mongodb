import BSON

extension BSONEncodable where Self == Mongo.Expression
{
    @inlinable public static
    func expr(with populate:(inout Mongo.ExpressionEncoder) throws -> ()) rethrows -> Self
    {
        var document:BSON.Document = .init()
        try populate(&document.output[as: Mongo.ExpressionEncoder.self])
        return .init(document)
    }
}
