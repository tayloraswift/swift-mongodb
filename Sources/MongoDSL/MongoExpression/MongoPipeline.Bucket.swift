import BSONEncoding

public
enum MongoPipeline
{
}

extension MongoPipeline
{
    @frozen public
    struct Bucket:Sendable
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
extension MongoPipeline.Bucket:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        self.fields.encode(to: &field)
    }
}
extension MongoPipeline.Bucket
{
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(bytes: [])
        try populate(&self)
    }
}

extension MongoPipeline.Bucket
{
    @frozen public
    enum GroupBy:String, Hashable, Sendable
    {
        case groupBy
    }
}
extension MongoPipeline.Bucket
{
    @frozen public
    enum Default:String, Hashable, Sendable
    {
        case `default`
    }
}
extension MongoPipeline.Bucket
{
    @frozen public
    enum Boundaries:String, Hashable, Sendable
    {
        case boundaries
    }
}
extension MongoPipeline.Bucket
{
    @inlinable public
    subscript<Encodable>(key:GroupBy) -> Encodable? where Encodable:MongoExpressionEncodable
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
    subscript<Encodable>(key:Default) -> Encodable? where Encodable:MongoExpressionEncodable
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
    subscript<Encodable>(key:Boundaries) -> Encodable? where Encodable:MongoExpressionEncodable
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
