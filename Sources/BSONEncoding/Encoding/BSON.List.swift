extension BSON.List
{
    @inlinable public
    init<Encodable>(elements:some Sequence<Encodable>) where Encodable:BSONFieldEncodable
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
    func append(_ element:some BSONFieldEncodable)
    {
        self.append(with: element.encode(to:))
    }

    /// Encodes and appends the given value if it is non-`nil`, does
    /// nothing otherwise.
    @inlinable public mutating
    func push(_ element:(some BSONFieldEncodable)?)
    {
        element.map
        {
            self.append($0)
        }
    }

    @available(*, deprecated, message: "use append(_:) for non-optional values")
    public mutating
    func push(_ element:some BSONFieldEncodable)
    {
        self.push(element as _?)
    }
}
extension BSON.List
{
    /// Encodes a nested list with the same DSL context as the current list.
    @inlinable public mutating
    func append(_ populate:(inout Self) throws -> ()) rethrows
    {
        self.append(try Self.init(with: populate))
    }
}
extension BSON.List where Document:BSONDSL & BSONFieldEncodable
{
    /// Encodes a nested document of type determined by this list’s DSL context.
    @inlinable public mutating
    func append(_ populate:(inout Document) throws -> ()) rethrows
    {
        self.append(try Document.init(with: populate))
    }
}

extension BSON.List:BSONFieldEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(list: .init(self))
    }
}
extension BSON.List:BSONEncodable where Document:BSONEncodable
{
}
