import BSONSchema

@frozen public
struct MongoQuery:Sendable
{
    public
    var fields:BSON.Fields

    @inlinable public
    init(bytes:[UInt8] = [])
    {
        self.fields = .init(bytes: bytes)
    }
}
extension MongoQuery:BSONDSL
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
extension MongoQuery:BSONEncodable
{
}
extension MongoQuery:BSONDecodable
{
}

extension MongoQuery
{
    @inlinable public
    subscript(key:BooleanOperator) -> Bool?
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
    subscript(key:MetatypeOperator) -> BSON?
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
    subscript(key:MetatypeOperator) -> [BSON]?
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
    @inlinable public
    subscript(key:RegexOperator) -> BSON.Regex?
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
extension MongoQuery
{
    @inlinable public
    subscript<Encodable>(key:BinaryOperator) -> Encodable?
        where Encodable:BSONEncodable
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
    subscript<Divisor, Encodable>(key:DivisionOperator) -> (by:Divisor, is:Encodable)?
        where Divisor:BSONEncodable, Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            guard let (divisor, value):(Divisor, Encodable) = value
            else
            {
                return
            }
            self[key.rawValue] = .init
            {
                $0.append(divisor)
                $0.append(value)
            }
        }
    }
}
extension MongoQuery
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
extension MongoQuery
{
    @inlinable public
    subscript(key:MongoQuery.TupleOperator) -> BSON.Elements<BSON.Fields>?
    {
        get
        {
            nil
        }
        set(value)
        {
            self[key.rawValue, elide: false] = value.map(BSON.Elements<Self>.init(_:))
        }
    }
}
