extension BSON.AnyType:BSONEncodable
{
    /// Encodes this metatype as a value of type ``BSON.AnyType/int32``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(int32: .init(self.rawValue))
    }
}
