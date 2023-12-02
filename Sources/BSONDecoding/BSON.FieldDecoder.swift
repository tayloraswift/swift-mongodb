extension BSON
{
    @available(*, deprecated, renamed: "FieldDecoder")
    public
    typealias ExplicitField = FieldDecoder
}
extension BSON
{
    @frozen public
    struct FieldDecoder<Key, Bytes> where Bytes:RandomAccessCollection<UInt8>, Key:Sendable
    {
        public
        let key:Key
        public
        let value:BSON.AnyValue<Bytes>

        @inlinable public
        init(key:Key, value:BSON.AnyValue<Bytes>)
        {
            self.key = key
            self.value = value
        }
    }
}
extension BSON.FieldDecoder:BSON.TraceableDecoder
{
    /// Decodes the value of this field with the given decoder.
    /// Throws a ``BSON/DecodingError`` wrapping the underlying
    /// error if decoding fails.
    @inlinable public
    func decode<T>(with decode:(BSON.AnyValue<Bytes>) throws -> T) throws -> T
    {
        do
        {
            return try decode(self.value)
        }
        catch let error
        {
            throw BSON.DecodingError.init(error, in: self.key)
        }
    }
}
