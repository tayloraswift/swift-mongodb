import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct PredicateOperator:Sendable
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
extension Mongo.PredicateOperator:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.PredicateOperator:BSONDecodable
{
}
extension Mongo.PredicateOperator:BSONEncodable
{
}

extension Mongo.PredicateOperator
{
    @inlinable public
    subscript(key:Exists) -> Bool?
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
    subscript(key:Metatype) -> BSON?
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
    subscript(key:Metatype) -> [BSON]?
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
    subscript(key:Regex) -> BSON.Regex?
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
}
extension Mongo.PredicateOperator
{
    @inlinable public
    subscript(key:Recursive) -> Self?
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
    subscript<Encodable>(key:Variadic) -> Encodable?
        where Encodable:BSONEncodable
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
    subscript<Encodable>(key:Binary) -> Encodable?
        where Encodable:BSONEncodable
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
    subscript<Divisor, Remainder>(key:Mod) -> (by:Divisor?, is:Remainder?)
        where Divisor:BSONEncodable, Remainder:BSONEncodable
    {
        get
        {
            (nil, nil)
        }
        set(value)
        {
            guard   let divisor:Divisor = value.by,
                    let remainder:Remainder = value.is
            else
            {
                return
            }
            self.document[key]
            {
                $0.append(divisor)
                $0.append(remainder)
            }
        }
    }
}
