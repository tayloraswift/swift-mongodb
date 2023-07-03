extension BSON:BSONEncodable
{
    /// Encodes this metatype as a value of type ``BSON.int32``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(int32: .init(self.rawValue))
    }
}
