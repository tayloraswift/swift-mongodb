import BSONUnions

/// A type that represents a scope for decoding operations.
public
protocol BSONScope<Bytes>
{
    associatedtype Bytes:RandomAccessCollection<UInt8>

    /// Attempts to load a BSON variant value and passes it to the given
    /// closure, returns its result. If decoding fails, the implementation
    /// should annotate the error with appropriate context and re-throw it.
    func decode<T>(with decode:(AnyBSON<Bytes>) throws -> T) throws -> T
}
extension BSONScope
{
    @inlinable public
    func decode<T>(as _:BSON.ListDecoder<Bytes.SubSequence>.Type,
        with decode:(BSON.ListDecoder<Bytes.SubSequence>) throws -> T) throws -> T
    {
        try self.decode { try decode(try $0.decoder()) }
    }
    @inlinable public
    func decode<T>(as _:BSON.DocumentDecoder<String, Bytes.SubSequence>.Type,
        with decode:(BSON.DocumentDecoder<String, Bytes.SubSequence>) throws -> T) throws -> T
    {
        try self.decode { try decode(try $0.decoder()) }
    }
    @inlinable public
    func decode<Key, T>(as _:BSON.DocumentDecoder<Key, Bytes.SubSequence>.Type,
        with decode:(BSON.DocumentDecoder<Key, Bytes.SubSequence>) throws -> T) throws -> T
        where Key:RawRepresentable<String>
    {
        try self.decode { try decode(try $0.decoder()) }
    }
    @inlinable public
    func decode<View, T>(as _:View.Type,
        with decode:(View) throws -> T) throws -> T where View:BSONDecodableView<Bytes>
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
