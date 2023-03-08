extension BSON.Document
{
    @inlinable public
    init<Encodable>(fields:__shared some Sequence<(key:String, value:Encodable)>)
        where Encodable:BSONEncodable
    {
        self.init()
        for (key, value):(String, Encodable) in fields
        {
            self.append(key, value)
        }
    }
}
extension BSON.Document:BSONDocumentBuilder
{
}
extension BSON.Document:BSONEncodable
{
}
extension BSON.Document
{
    @inlinable public
    init(encoding encodable:__shared some BSONDocumentEncodable)
    {
        self.init(with: encodable.encode(to:))
    }
    @inlinable public
    init<CodingKeys>(_:CodingKeys.Type = CodingKeys.self,
        with populate:(inout BSON.DocumentEncoder<CodingKeys>) throws -> ()) rethrows
    {
        self.init()
        try populate(&self.output[as: BSON.DocumentEncoder<CodingKeys>.self])
    }
    @inlinable public
    init(with populate:(inout BSON.DocumentEncoder<BSON.Key>) throws -> ()) rethrows
    {
        self.init()
        try populate(&self.output[as: BSON.DocumentEncoder<BSON.Key>.self])
    }
}
extension BSON.Document
{
    @inlinable public mutating
    func append(_ key:some RawRepresentable<String>, _ value:some BSONFieldEncodable)
    {
        self.append(key.rawValue, value)
    }

    @inlinable public mutating
    func push(_ key:some RawRepresentable<String>, _ value:(some BSONFieldEncodable)?)
    {
        value.map
        {
            self.append(key, $0)
        }
    }

    @available(*, deprecated, message: "use append(_:_:) for non-optional values")
    public mutating
    func push(_ key:some RawRepresentable<String>, _ value:some BSONFieldEncodable)
    {
        self.push(key, value as _?)
    }
}
extension BSON.Document
{
    @inlinable public
    subscript(_ key:some RawRepresentable<String>,
        with encode:(inout BSON.ListEncoder) -> ()) -> Void
    {
        mutating get
        {
            self[key.rawValue, with: encode]
        }
    }
    @inlinable public
    subscript(_ key:some RawRepresentable<String>,
        with encode:(inout BSON.DocumentEncoder<BSON.Key>) -> ()) -> Void
    {
        mutating get
        {
            self[key.rawValue, with: encode]
        }
    }
    @inlinable public
    subscript<CodingKeys>(_ key:some RawRepresentable<String>,
        using _:CodingKeys.Type = CodingKeys.self,
        with encode:(inout BSON.DocumentEncoder<CodingKeys>) -> ()) -> Void
    {
        mutating get
        {
            self[key.rawValue, with: encode]
        }
    }
}
