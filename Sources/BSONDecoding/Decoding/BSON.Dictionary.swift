import BSONUnions

extension BSON
{
    /// A thin wrapper around a native Swift dictionary providing an efficient decoding
    /// interface for a ``BSON/Document``.
    @frozen public
    struct Dictionary<Bytes> where Bytes:RandomAccessCollection<UInt8>
    {
        public
        var items:[String: AnyBSON<Bytes>]
        
        @inlinable public
        init(_ items:[String: AnyBSON<Bytes>] = [:])
        {
            self.items = items
        }
    }
}
extension BSON.Dictionary
{
    @inlinable public
    subscript(key:String) -> BSON.ExplicitField<String, Bytes>?
    {
        self.items[key].map { .init(key: key, value: $0) }
    }
    @inlinable public
    subscript(key:String) -> BSON.ImplicitField<Bytes>
    {
        .init(key: key, value: self.items[key])
    }
}
