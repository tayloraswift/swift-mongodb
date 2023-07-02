extension BSON.ListView:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(list: self)
    }
}
