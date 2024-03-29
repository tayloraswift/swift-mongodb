extension BSON.Regex:BSONEncodable
{
    /// Encodes this regex as a value of type ``BSON.AnyType/regex``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(regex: self)
    }
}
