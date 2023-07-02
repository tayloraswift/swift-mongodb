extension BSON.DocumentView:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: self)
    }
}
