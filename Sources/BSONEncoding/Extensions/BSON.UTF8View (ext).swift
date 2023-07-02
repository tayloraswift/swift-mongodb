extension BSON.UTF8View:BSONEncodable
{
    /// Encodes this UTF-8 string as a ``BSON.string``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(string: self)
    }
}
