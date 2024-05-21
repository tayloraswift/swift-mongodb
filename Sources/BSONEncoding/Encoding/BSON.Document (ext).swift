extension BSON.Document:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(document: self)
    }
}
extension BSON.Document
{
    @inlinable public
    subscript<CodingKey>(_:CodingKey.Type) -> BSON.DocumentEncoder<CodingKey>
    {
        mutating
        _read   { yield  self.output[as: BSON.DocumentEncoder<CodingKey>.self] }
        _modify { yield &self.output[as: BSON.DocumentEncoder<CodingKey>.self] }
    }
}
extension BSON.Document
{
    @inlinable public
    subscript(with key:some RawRepresentable<String>) -> BSON.FieldEncoder
    {
        _read   { yield  self.output[with: .init(key)] }
        _modify { yield &self.output[with: .init(key)] }
    }
}

extension BSON.Document
{
    @inlinable public
    init<Encodable>(encoding fields:__shared some Sequence<(key:BSON.Key, value:Encodable)>)
        where Encodable:BSONEncodable
    {
        self.init
        {
            for (key, value):(BSON.Key, Encodable) in fields
            {
                $0[key] = value
            }
        }
    }
    @inlinable public
    init(encoding encodable:__shared some BSONDocumentEncodable)
    {
        self.init(with: encodable.encode(to:))
    }

    @inlinable public
    init<CodingKey>(_:CodingKey.Type = CodingKey.self,
        with encode:(inout BSON.DocumentEncoder<CodingKey>) throws -> ()) rethrows
    {
        self.init()
        try encode(&self.output[as: BSON.DocumentEncoder<CodingKey>.self])
    }
}

@available(*, unavailable, message: "These APIs have moved to BSON.Document")
extension BSONEncodable where Self == BSON.Document
{
    @inlinable public
    init<Encodable>(encoding fields:__shared some Sequence<(key:BSON.Key, value:Encodable)>)
        where Encodable:BSONEncodable
    {
        self.init
        {
            for (key, value):(BSON.Key, Encodable) in fields
            {
                $0[key] = value
            }
        }
    }
    @inlinable public
    init(encoding encodable:__shared some BSONDocumentEncodable)
    {
        self.init(with: encodable.encode(to:))
    }

    @inlinable public
    init<CodingKey>(_:CodingKey.Type = CodingKey.self,
        with populate:(inout BSON.DocumentEncoder<CodingKey>) throws -> ()) rethrows
    {
        self.init()
        try populate(&self.output[as: BSON.DocumentEncoder<CodingKey>.self])
    }
}
