extension BSON.DocumentView:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(document: self)
    }
}
