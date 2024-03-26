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

@available(*, unavailable, message: "Currently useless due to a compiler bug!")
extension BSONEncodable where Self == BSON.Min
{
    /// A shorthand for encoding a ``BSON.Min`` value.
    @inlinable public static
    var min:Self { .init() }
}
@available(*, unavailable, message: "Currently useless due to a compiler bug!")
extension BSONEncodable where Self == BSON.Max
{
    /// A shorthand for encoding a ``BSON.Max`` value.
    @inlinable public static
    var max:Self { .init() }
}
@available(*, unavailable, message: "Currently useless due to a compiler bug!")
extension BSONEncodable where Self == BSON.Null
{
    /// A shorthand for encoding an explicit ``BSON.Null`` value.
    @inlinable public static
    var null:Self { .init() }
}
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
        field.encode(timestamp: .init(self))
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
        field.encode(timestamp: .init(UInt64.init(self)))
    }
}
