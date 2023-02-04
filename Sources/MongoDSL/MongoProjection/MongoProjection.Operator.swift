import BSONDecoding
import BSONEncoding

extension MongoProjection
{
    @frozen public
    struct Operator:Sendable
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
extension MongoProjection.Operator:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoProjection.Operator:BSONEncodable
{
}
extension MongoProjection.Operator:BSONDecodable
{
}

extension MongoProjection.Operator
{
    @inlinable public
    subscript(key:First) -> MongoPredicate?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key] = value
        }
    }
}
extension MongoProjection.Operator
{
    @inlinable public
    subscript(key:Meta) -> MongoProjection.Metadata?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key] = value
        }
    }
}
extension MongoProjection.Operator
{
    @inlinable public
    subscript<Distance>(key:Slice) -> Distance?
        where Distance:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key] = value
        }
    }
    @inlinable public
    subscript<Index, Count>(key:Slice) -> (at:Index?, count:Count?)
        where Index:BSONEncodable, Count:BSONEncodable
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            guard let count:Count = value.count
            else
            {
                return
            }
            self.fields[pushing: key] = .init
            {
                if let index:Index = value.at
                {
                    $0.append(index)
                }
                $0.append(count)
            }
        }
    }
}
