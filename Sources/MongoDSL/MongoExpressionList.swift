import BSONEncoding

@frozen public
struct MongoExpressionList:MongoExpressionEncodable, BSONRepresentable, Sendable
{
    public
    var bson:BSON.List

    @inlinable public
    init(_ bson:BSON.List)
    {
        self.bson = bson
    }
}
extension MongoExpressionList
{
    @inlinable public
    init(with populate:(inout MongoExpressionList.Encoder) throws -> ()) rethrows
    {
        self.init(.init())
        try populate(&self.bson.output[as: MongoExpressionList.Encoder.self])
    }
}
extension MongoExpressionList?
{
    @_disfavoredOverload
    @inlinable public
    init(with populate:(inout MongoExpressionList.Encoder) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
