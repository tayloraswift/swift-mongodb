extension BSON.List:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(list: .init(self))
    }
}
