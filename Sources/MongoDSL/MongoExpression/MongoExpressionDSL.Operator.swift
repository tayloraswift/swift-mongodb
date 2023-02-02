import BSONEncoding

extension MongoExpressionDSL
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
extension MongoExpressionDSL.Operator
{
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(bytes: [])
        try populate(&self)
    }
}
extension MongoExpressionDSL.Operator:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.fields.encode(to: &field)
    }
}
extension MongoExpressionDSL.Operator:MongoExpressionEncodable
{
}

extension MongoExpressionDSL.Operator?
{
    @inlinable public
    init(with populate:(inout Wrapped) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}


extension MongoExpressionDSL.Operator
{
    @frozen public
    enum Unary:String, Hashable, Sendable
    {
        case abs = "$abs"
        case literal = "$literal"
    }
}
extension MongoExpressionDSL.Operator
{
    @frozen public
    enum Variadic:String, Hashable, Sendable
    {
        case add = "$add"
    }
}
extension MongoExpressionDSL.Operator
{
    @inlinable public
    subscript<Encodable>(key:Unary) -> Encodable? where Encodable:MongoExpressionEncodable
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
    subscript<T0, T1>(key:Variadic) -> (T0?, T1?)
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
                $0.append(value.0)
                $0.append(value.1)
            }
        }
    }
    @inlinable public
    subscript<Encodable>(key:Variadic) -> Encodable? where Encodable:MongoExpressionEncodable
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
