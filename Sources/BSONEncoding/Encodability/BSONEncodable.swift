import BSONABI

/// A type that can be encoded to a BSON variant value.
public
protocol BSONEncodable
{
    func encode(to field:inout BSON.FieldEncoder)
}
extension BSONEncodable where Self:BSONRepresentable, BSONRepresentation:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.bson.encode(to: &field)
    }
}
extension BSONEncodable where Self:RawRepresentable, RawValue:BSONEncodable
{
    /// Returns the ``encode(to:) [7NT06]`` witness of this type’s
    /// ``RawRepresentable/rawValue``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.rawValue.encode(to: &field)
    }
}

extension BSONEncodable where Self == BSON.Document
{
    @inlinable public
    init<Encodable>(encoding fields:__shared some Sequence<(key:String, value:Encodable)>)
        where Encodable:BSONEncodable
    {
        self.init()
        for (key, value):(String, Encodable) in fields
        {
            self.append(key, value)
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
    @inlinable public
    init(with populate:(inout BSON.DocumentEncoder<BSON.Key>) throws -> ()) rethrows
    {
        self.init()
        try populate(&self.output[as: BSON.DocumentEncoder<BSON.Key>.self])
    }
}
extension BSONEncodable where Self == BSON.List
{
    /// Creates an empty list, and initializes it with the given closure.
    @inlinable public
    init(with populate:(inout BSON.ListEncoder) throws -> ()) rethrows
    {
        self.init()
        try populate(&self.output[as: BSON.ListEncoder.self])
    }

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
}

@available(*, deprecated,
    message: "UInt64 is not recommended for BSON that will be handled by MongoDB.")
extension UInt64:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.AnyType/uint64``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(uint64: self)
    }
}
@available(*, deprecated,
    message: "UInt is not recommended for BSON that will be handled by MongoDB.")
extension UInt:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.AnyType/uint64``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(uint64: .init(self))
    }
}
