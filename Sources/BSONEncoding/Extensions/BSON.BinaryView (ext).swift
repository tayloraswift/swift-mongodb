extension BSON.BinaryView:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(binary: self)
    }
}
