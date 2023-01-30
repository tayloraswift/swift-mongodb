import BSONSchema

extension MongoQuery
{
    @frozen public
    struct Document:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension MongoQuery.Document:BSONDSL
{
    public
    typealias Subdocument = MongoQuery

    @inlinable public mutating
    func append(key:String, with serialize:(inout BSON.Field) -> ())
    {
        self.fields.append(key: key, with: serialize)
    }
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoQuery.Document:BSONEncodable
{
}
extension MongoQuery.Document:BSONDecodable
{
}
extension MongoQuery.Document
{
    @inlinable public
    subscript(key:LogicalOperator) -> BSON.Elements<Self>?
    {
        get
        {
            nil
        }
        set(value)
        {
            self[key.rawValue, elide: false] = value
        }
    }
    @inlinable public
    subscript<Encodable>(key:Operator) -> Encodable? where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self[key.rawValue] = value
        }
    }
    @inlinable public
    subscript(key:ExpressionOperator) -> MongoExpression?
    {
        get
        {
            nil
        }
        set(value)
        {
            self[key.rawValue] = value
        }
    }
}
