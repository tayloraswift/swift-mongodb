extension Substring:BSONEncodable
{
    /// Encodes this substring as a value of type ``BSON.string``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(string: .init(self))
    }
}
