extension BSON.Millisecond:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(millisecond: self)
    }
}
