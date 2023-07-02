extension BSON.Identifier:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(id: self)
    }
}
