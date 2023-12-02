extension Double:BSONEncodable
{
    /// Encodes this metatype as a value of type ``BSON.double``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(double: .init(self))
    }
}
