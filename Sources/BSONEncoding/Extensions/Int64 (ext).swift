extension Int64:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.AnyType/int64``. It will always use
    /// the 64-bit representation, even if it would fit in a ``BSON.AnyType/int32``. To use
    /// a variable-length encoding, encode an ``Int`` instead.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(int64: self)
    }
}
