import BSON

extension Mongo
{
    @frozen public
    struct ZipDocument:MongoDocumentDSL, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
    }
}
extension Mongo.ZipDocument
{
    @inlinable public
    subscript<Encodable>(key:Inputs) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(key, value)
        }
    }
    @inlinable public
    subscript<T0, T1>(key:Inputs) -> (T0?, T1?)
        where   T0:BSONEncodable,
                T1:BSONEncodable
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            self.bson[key]
            {
                $0.push(value.0)
                $0.push(value.1)
            }
        }
    }
    @inlinable public
    subscript<T0, T1, T2>(key:Inputs) -> (T0?, T1?, T2?)
        where   T0:BSONEncodable,
                T1:BSONEncodable,
                T2:BSONEncodable
    {
        get
        {
            (nil, nil, nil)
        }
        set(value)
        {
            self.bson[key]
            {
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
            }
        }
    }
    @inlinable public
    subscript<T0, T1, T2, T3>(key:Inputs) -> (T0?, T1?, T2?, T3?)
        where   T0:BSONEncodable,
                T1:BSONEncodable,
                T2:BSONEncodable,
                T3:BSONEncodable
    {
        get
        {
            (nil, nil, nil, nil)
        }
        set(value)
        {
            self.bson[key]
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
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:Encodable = value
            {
                self.bson.append(key, value)
                self.bson.append("useLongestLength", true)
            }
        }
    }
}
