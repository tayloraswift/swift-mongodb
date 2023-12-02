extension BSON.Millisecond:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(millisecond: self)
    }
}
