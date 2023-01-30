import BSONSchema

extension MongoProjection
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
extension MongoProjection.Document:BSONDSL
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
extension MongoProjection.Document:BSONEncodable
{
}
extension MongoProjection.Document:BSONDecodable
{
}
extension MongoProjection.Document
{
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
extension MongoProjection.Document
{
    @inlinable public
    subscript(key:MetadataOperator) -> MongoProjection.Metadata?
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
extension MongoProjection.Document
{
    @inlinable public
    subscript(key:Operator) -> Self?
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
}
extension MongoProjection.Document
{
    @inlinable public
    subscript<Distance>(key:RangeOperator) -> Distance?
        where Distance:BSONEncodable
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
    subscript<Index, Count>(key:RangeOperator) -> (at:Index, count:Count)?
        where Index:BSONEncodable, Count:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            guard let (index, count):(Index, Count) = value
            else
            {
                return
            }
            self[key.rawValue] = .init
            {
                $0.append(index)
                $0.append(count)
            }
        }
    }
}
