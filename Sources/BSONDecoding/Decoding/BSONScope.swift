/// A type that represents a scope for decoding operations.
public
protocol BSONScope<Bytes>
{
    associatedtype Bytes:RandomAccessCollection<UInt8>

    /// Attempts to load a BSON variant value and passes it to the given
    /// closure, returns its result. If decoding fails, the implementation
    /// should annotate the error with appropriate context and re-throw it.
    func decode<T>(with decode:(BSON.AnyValue<Bytes>) throws -> T) throws -> T
}
extension BSONScope
{
    @inlinable public
    func decode<CodingKeys, T>(using _:CodingKeys.Type = CodingKeys.self,
        with decode:(BSON.DocumentDecoder<CodingKeys, Bytes>) throws -> T) throws -> T
    {
        try self.decode { try decode(try .init(parsing: $0)) }
    }
    @inlinable public
    func decode<T>(with decode:(BSON.DocumentDecoder<BSON.Key, Bytes>) throws -> T) throws -> T
    {
        try self.decode { try decode(try .init(parsing: $0)) }
    }
    @inlinable public
    func decode<T>(with decode:(BSON.ListDecoder<Bytes>) throws -> T) throws -> T
    {
        try self.decode { try decode(try .init(parsing: $0)) }
    }
    //  Right now, this is mainly useful for decoding custom ``BSON.BinaryView`` buffers.
    //  We should probably replace this with a dedicated API for binary subschema.
    @inlinable public
    func decode<View, T>(as _:View.Type,
        with decode:(View) throws -> T) throws -> T where View:BSONView<Bytes>
    {
        try self.decode { try decode(try .init($0)) }
    }
    @inlinable public
    func decode<Decodable, T>(as _:Decodable.Type,
        with decode:(Decodable) throws -> T) throws -> T where Decodable:BSONDecodable
    {
        try self.decode { try decode(try .init(bson: $0)) }
    }
    @inlinable public
    func decode<Decodable>(
        to _:Decodable.Type = Decodable.self) throws -> Decodable where Decodable:BSONDecodable
    {
        try self.decode(with: Decodable.init(bson:))
    }
}
