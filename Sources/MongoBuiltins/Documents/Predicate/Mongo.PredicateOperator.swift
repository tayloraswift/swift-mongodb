import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct PredicateOperator:BSONRepresentable, BSONDSL, Sendable
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson[key]
            {
                $0.append(divisor)
                $0.append(remainder)
            }
        }
    }
}
