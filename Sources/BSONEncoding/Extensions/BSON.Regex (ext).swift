extension BSON.Regex:BSONEncodable
{
    /// Encodes this regex as a value of type ``BSON.regex``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(regex: self)
    }
}
