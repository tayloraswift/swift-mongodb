extension Unicode.Scalar:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.description.encode(to: &field)
    }
}