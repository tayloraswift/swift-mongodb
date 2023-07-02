extension Int32:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.int32``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(int32: self)
    }
}
