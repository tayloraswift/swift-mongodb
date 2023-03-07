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
extension BSON.Document:BSONBuilder
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
    init<CodingKeys>(
        with populate:(inout BSON.DocumentEncoder<CodingKeys>) throws -> ()) rethrows
    {
        self.init()
        try self.encode(CodingKeys.self, with: populate)
    }
    @inlinable public mutating
    func encode<CodingKeys>(_:CodingKeys.Type = CodingKeys.self,
        with encode:(inout BSON.DocumentEncoder<CodingKeys>) throws -> ()) rethrows
    {
        try self.output.with(BSON.DocumentEncoder<CodingKeys>.self, do: encode)
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
    @inlinable public mutating
    func append<Encoder>(_ key:some RawRepresentable<String>,
        with _:Encoder.Type = BSON.ListEncoder.self,
        do encode:(inout Encoder) -> ()) where Encoder:BSONEncoder
    {
        self.append(key.rawValue, with: Encoder.self, do: encode)
    }
}
