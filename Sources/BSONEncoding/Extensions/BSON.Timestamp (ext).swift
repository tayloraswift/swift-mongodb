extension BSON.Timestamp:BSONEncodable
{
    /// Encodes this timestamp as a ``BSON.AnyValue/uint64(_:)``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(timestamp: self)
    }
}
