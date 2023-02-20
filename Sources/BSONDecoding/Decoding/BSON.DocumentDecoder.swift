import BSONUnions

extension BSON
{
    /// A thin wrapper around a native Swift dictionary providing an efficient decoding
    /// interface for a ``BSON/DocumentView``.
    @frozen public
    struct DocumentDecoder<CodingKey, Bytes>
        where CodingKey:Hashable, Bytes:RandomAccessCollection<UInt8>
    {
        public
        var index:[CodingKey: AnyBSON<Bytes>]
        
        @inlinable public
        init(_ index:[CodingKey: AnyBSON<Bytes>] = [:])
        {
            self.index = index
        }
    }
}
extension BSON.DocumentDecoder
{
    @inlinable public
    subscript(key:CodingKey) -> BSON.ExplicitField<CodingKey, Bytes>?
    {
        self.index[key].map { .init(key: key, value: $0) }
    }
    @inlinable public
    subscript(key:CodingKey) -> BSON.ImplicitField<CodingKey, Bytes>
    {
        .init(key: key, value: self.index[key])
    }
}
