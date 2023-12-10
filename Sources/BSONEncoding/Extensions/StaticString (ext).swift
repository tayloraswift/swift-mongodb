extension StaticString:BSONEncodable
{
    /// Encodes this string as a value of type ``BSON.AnyType/string``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(string: .init(self))
    }
}
