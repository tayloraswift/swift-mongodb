extension BSON.Elements
{
    @inlinable public
    init<Encodable>(elements:some Sequence<Encodable>) where Encodable:BSONDSLEncodable
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
    func append(_ element:some BSONDSLEncodable)
    {
        self.append(with: element.encode(to:))
    }
    @inlinable public mutating
    func append(_ populate:(inout Self) throws -> ()) rethrows
    {
        let nested:Self = try .init(with: populate)
        self.append(nested)
    }
}
extension BSON.Elements
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(list: .init(self))
    }
}
extension BSON.Elements:BSONDSLEncodable
{
}
extension BSON.Elements where DSL:BSONDSL & BSONDSLEncodable
{
    @inlinable public mutating
    func append(_ populate:(inout DSL) throws -> ()) rethrows
    {
        self.append(try DSL.init(with: populate))
    }
}

extension BSON.Elements<BSON.Fields>:BSONEncodable
{
    @inlinable public mutating
    func push(_ element:(some BSONEncodable)?)
    {
        element.map
        {
            self.append($0)
        }
    }
}
