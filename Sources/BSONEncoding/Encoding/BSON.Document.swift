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
    @inlinable public mutating
    func append(_ key:String, _ value:some BSONStreamEncodable)
    {
        self.append(key, with: value.encode(to:))
    }
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
