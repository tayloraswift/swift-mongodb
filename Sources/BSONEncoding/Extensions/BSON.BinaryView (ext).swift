extension BSON.BinaryView:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(binary: self)
    }
}
