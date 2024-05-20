import BSON

extension Mongo.ZipDocument
{
    @frozen public
    struct Encoder
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<BSON.Key>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.ZipDocument.Encoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}

extension Mongo.ZipDocument.Encoder
{
    @frozen public
    enum Inputs:String, Hashable, Sendable
    {
        case inputs
    }

    @frozen public
    enum Defaults:String, Hashable, Sendable
    {
        case defaults
    }
}

extension Mongo.ZipDocument.Encoder
{
    @inlinable public
    subscript<Encodable>(key:Inputs) -> Encodable?
        where Encodable:BSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
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
            {
                $0.push(value.0)
                $0.push(value.1)
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
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
            {
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
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
            {
                $0.push(value.0)
                $0.push(value.1)
                $0.push(value.2)
                $0.push(value.3)
            } (&self.bson[with: key][as: BSON.ListEncoder.self])
        }
    }

    /// This subscript automatically sets `useLongestLength` if set to a
    /// non-nil value.
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
            if  let value:Encodable = value
            {
                value.encode(to: &self.bson[with: key])
                true.encode(to: &self.bson[with: "useLongestLength" as BSON.Key])
            }
        }
    }
}
