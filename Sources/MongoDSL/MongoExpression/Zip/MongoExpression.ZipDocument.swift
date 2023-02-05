import BSONEncoding

extension MongoExpression
{
    @frozen public
    struct ZipDocument:Sendable
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
extension MongoExpression.ZipDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoExpression.ZipDocument:BSONEncodable
{
}
extension MongoExpression.ZipDocument
{
    @inlinable public
    subscript<Encodable>(key:Inputs) -> Encodable?
        where Encodable:MongoExpressionEncodable
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
    subscript<T0, T1>(key:Inputs) -> (T0?, T1?)
        where   T0:MongoExpressionEncodable,
                T1:MongoExpressionEncodable
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            self[key] = .init
            {
                $0.push(value.0)
                $0.push(value.1)
            }
        }
    }
    @inlinable public
    subscript<T0, T1, T2>(key:Inputs) -> (T0?, T1?, T2?)
        where   T0:MongoExpressionEncodable,
                T1:MongoExpressionEncodable,
                T2:MongoExpressionEncodable
    {
        get
        {
            (nil, nil, nil)
        }
        set(value)
        {
            self[key] = .init
            {
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
            }
        }
    }
    @inlinable public
    subscript<T0, T1, T2, T3>(key:Inputs) -> (T0?, T1?, T2?, T3?)
        where   T0:MongoExpressionEncodable,
                T1:MongoExpressionEncodable,
                T2:MongoExpressionEncodable,
                T3:MongoExpressionEncodable
    {
        get
        {
            (nil, nil, nil, nil)
        }
        set(value)
        {
            self[key] = .init
            {
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
                $0.push(value.3)
            }
        }
    }

    /// This subscript automatically sets `useLongestLength` if set to a
    /// non-[`nil`]() value.
    @inlinable public
    subscript<Encodable>(key:Defaults) -> Encodable?
        where Encodable:MongoExpressionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Encodable = value
            {
                self.fields[pushing: key] = value
                self.fields[pushing: "useLongestLength"] = true
            }
        }
    }
}
