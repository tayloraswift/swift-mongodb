import BSONUnions

extension BSON
{
    @frozen public
    struct ExplicitField<Key, Bytes> where Bytes:RandomAccessCollection<UInt8>
    {
        public
        let key:Key
        public
        let value:AnyBSON<Bytes>

        @inlinable public
        init(key:Key, value:AnyBSON<Bytes>)
        {
            self.key = key
            self.value = value
        }
    }
}
extension BSON.ExplicitField:BSONScope
{
    /// Decodes the value of this field with the given decoder.
    /// Throws a ``BSON/DecodingError`` wrapping the underlying
    /// error if decoding fails.
    @inlinable public
    func decode<T>(with decode:(AnyBSON<Bytes>) throws -> T) throws -> T
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
