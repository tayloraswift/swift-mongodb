extension String:BSONEncodable
{
    /// Encodes this string as a value of type ``BSON.AnyType/string``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(string: BSON.UTF8View<Self.UTF8View>.init(self))
    }
}
