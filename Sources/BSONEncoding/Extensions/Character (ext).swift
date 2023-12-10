extension Character:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.description.encode(to: &field)
    }
}
