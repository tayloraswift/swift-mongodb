extension Int32:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.AnyType/int32``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(int32: self)
    }
}
