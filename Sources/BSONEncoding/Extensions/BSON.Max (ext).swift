extension BSON.Max:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(max: self)
    }
}
