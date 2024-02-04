extension Never:BSONDecodable
{
    /// Always throws a ``BSON.TypecastError``.
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        throw BSON.TypecastError<Never>.init(invalid: bson.type)
    }
}
