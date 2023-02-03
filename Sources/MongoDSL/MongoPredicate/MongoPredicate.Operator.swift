import BSONSchema

extension MongoPredicate
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
extension MongoPredicate.Operator:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoPredicate.Operator:BSONDecodable
{
}
extension MongoPredicate.Operator:BSONEncodable
{
}
@available(*, unavailable)
extension MongoPredicate.Operator:MongoPredicateEncodable
{
}

extension MongoPredicate.Operator
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
            self.fields[key.rawValue] = value
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
            self.fields[key.rawValue] = value
        }
    }
    @inlinable public
    subscript(key:Metatype) -> [BSON]
    {
        get
        {
            []
        }
        set(value)
        {
            self.fields[key.rawValue, elide: false] = value
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
            self.fields[key.rawValue] = value
        }
    }
}
extension MongoPredicate.Operator
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
            self.fields[key.rawValue, elide: false] = value
        }
    }

    @inlinable public
    subscript<Encodable>(key:Variadic) -> Encodable?
        where Encodable:MongoPredicateEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key.rawValue] = value
        }
    }

    @inlinable public
    subscript<Encodable>(key:Binary) -> Encodable?
        where Encodable:MongoPredicateEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key.rawValue] = value
        }
    }
    @inlinable public
    subscript<Divisor, Remainder>(key:Mod) -> (by:Divisor?, is:Remainder?)
        where Divisor:MongoPredicateEncodable, Remainder:MongoPredicateEncodable
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
            self.fields[key.rawValue] = .init
            {
                $0.append(divisor)
                $0.append(remainder)
            }
        }
    }
}
