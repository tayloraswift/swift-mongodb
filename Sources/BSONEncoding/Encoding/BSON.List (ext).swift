extension BSON.List:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(list: BSON.ListView.init(self))
    }
}
