extension BSON.List
{
    @inlinable public
    init<Encodable>(elements:some Sequence<Encodable>) where Encodable:BSONStreamEncodable
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
    func append(_ populate:(inout Self) throws -> ()) rethrows
    {
        self.append(try Self.init(with: populate))
    }
    @inlinable public mutating
    func append(_ element:some BSONStreamEncodable)
    {
        self.append(with: element.encode(to:))
    }

    /// Encodes and appends the given value if it is non-`nil`, does
    /// nothing otherwise.
    @inlinable public mutating
    func push(_ element:(some BSONStreamEncodable)?)
    {
        element.map
        {
            self.append($0)
        }
    }

    @available(*, deprecated, message: "use append(_:) for non-optional values")
    public mutating
    func push(_ element:some BSONStreamEncodable)
    {
        self.push(element as _?)
    }
}
extension BSON.List where DSL:BSONStream & BSONStreamEncodable
{
    @inlinable public mutating
    func append(_ populate:(inout DSL) throws -> ()) rethrows
    {
        self.append(try DSL.init(with: populate))
    }
}

extension BSON.List:BSONStreamEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(list: .init(self))
    }
}
extension BSON.List:BSONEncodable where DSL:BSONBuilder
{
}
