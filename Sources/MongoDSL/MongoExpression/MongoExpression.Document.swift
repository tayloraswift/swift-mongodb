import BSONSchema

extension MongoExpression
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
extension MongoExpression.Document:BSONDSL
{
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
extension MongoExpression.Document:BSONEncodable
{
}
extension MongoExpression.Document:BSONDecodable
{
}
extension MongoExpression.Document
{
    //  We need this because swift cannot use leading dot syntax if the
    //  type context is both optional and generic. (It can use leading-dot
    //  syntax if the type context is generic but non-optional.)
    @inlinable public
    subscript(key:String) -> MongoExpression?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:MongoExpression
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }
}
