extension String:BSONEncodable
{
    /// Encodes this string as a value of type ``BSON.string``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(string: .init(self))
    }
}
