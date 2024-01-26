extension BSON.Null:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(null: self)
    }
}
