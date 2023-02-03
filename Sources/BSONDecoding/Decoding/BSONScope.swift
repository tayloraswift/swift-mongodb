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
    func decode<T>(as _:BSON.Array<Bytes.SubSequence>.Type,
        with decode:(BSON.Array<Bytes.SubSequence>) throws -> T) throws -> T
    {
        try self.decode { try decode(try $0.array()) }
    }
    @inlinable public
    func decode<T>(as _:BSON.Dictionary<Bytes.SubSequence>.Type,
        with decode:(BSON.Dictionary<Bytes.SubSequence>) throws -> T) throws -> T
    {
        try self.decode { try decode(try $0.dictionary()) }
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
