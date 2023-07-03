extension Never:BSONDecodable
{
    /// Always throws a ``BSON.TypecastError``.
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        throw BSON.TypecastError<Never>.init(invalid: bson.type)
    }
}
