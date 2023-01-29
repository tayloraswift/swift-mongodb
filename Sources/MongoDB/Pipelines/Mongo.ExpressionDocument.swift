import BSONSchema

extension Mongo
{
    @frozen public
    struct ExpressionDocument
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
extension Mongo.ExpressionDocument:BSONDSL
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
extension Mongo.ExpressionDocument:BSONEncodable
{
}
extension Mongo.ExpressionDocument:BSONDecodable
{
}
extension Mongo.ExpressionDocument
{
    //  We need this because swift cannot use leading dot syntax if the
    //  type context is both optional and generic. (It can use leading-dot
    //  syntax if the type context is generic but non-optional.)
    @inlinable public
    subscript(key:String) -> Mongo.Expression?
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Mongo.Expression
            {
                self.append(key: key, with: value.encode(to:))
            }
        }
    }
}
