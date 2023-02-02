extension BSON.Elements
{
    @inlinable public
    init<Encodable>(elements:some Sequence<Encodable>) where Encodable:BSONEncodable
    {
        self.init
        {
            for element:Encodable in elements
            {
                $0.append(element)
            }
        }
    }
    @inlinable public mutating
    func append(_ element:some BSONEncodable)
    {
        self.append(with: element.encode(to:))
    }
    @inlinable public mutating
    func append(_ populate:(inout Self) throws -> ()) rethrows
    {
        let nested:Self = try .init(with: populate)
        self.append(with: nested.encode(to:))
    }
}
extension BSON.Elements where DSL:BSONDSL & BSONEncodable
{
    @inlinable public mutating
    func append(_ populate:(inout DSL) throws -> ()) rethrows
    {
        self.append(try DSL.init(with: populate))
    }
}
extension BSON.Elements
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(tuple: .init(self))
    }
}
extension BSON.Elements:BSONEncodable
{
}
