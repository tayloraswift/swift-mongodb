extension BSON.Document:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(self))
    }
}
extension BSON.Document:BSONBuilder
{
}
extension BSON.Document
{
    @inlinable public mutating
    func append(_ key:some RawRepresentable<String>, _ value:some BSONEncodable)
    {
        self.append(key.rawValue, value)
    }

    @inlinable public mutating
    func push(_ key:some RawRepresentable<String>, _ value:(some BSONEncodable)?)
    {
        value.map
        {
            self.append(key, $0)
        }
    }

    @available(*, deprecated, message: "use append(_:_:) for non-optional values")
    public mutating
    func push(_ key:some RawRepresentable<String>, _ value:some BSONEncodable)
    {
        self.push(key, value as _?)
    }
}
extension BSON.Document
{
    @inlinable public
    subscript(key:some RawRepresentable<String>,
        with encode:(inout BSON.ListEncoder) -> ()) -> Void
    {
        mutating get
        {
            self[key.rawValue, with: encode]
        }
    }
    @inlinable public
    subscript(key:some RawRepresentable<String>,
        with encode:(inout BSON.DocumentEncoder<BSON.Key>) -> ()) -> Void
    {
        mutating get
        {
            self[key.rawValue, with: encode]
        }
    }
    @inlinable public
    subscript<CodingKey>(key:some RawRepresentable<String>,
        using _:CodingKey.Type = CodingKey.self,
        with encode:(inout BSON.DocumentEncoder<CodingKey>) -> ()) -> Void
    {
        mutating get
        {
            self[key.rawValue, with: encode]
        }
    }
}
