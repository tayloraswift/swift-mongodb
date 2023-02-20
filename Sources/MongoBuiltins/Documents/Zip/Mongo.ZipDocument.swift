import BSONEncoding

extension Mongo
{
    @frozen public
    struct ZipDocument:Sendable
    {
        public
        var document:BSON.Document

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.document = .init(bytes: bytes)
        }
    }    
}
extension Mongo.ZipDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.ZipDocument:BSONEncodable
{
}
extension Mongo.ZipDocument
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
            self.document.push(key, value)
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
                self.document.append(key, value)
                self.document.append("useLongestLength", true)
            }
        }
    }
}
