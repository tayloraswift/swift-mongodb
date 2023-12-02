extension Never:BSONEncodable
{
    /// ``Never`` encodes anything.
    @inlinable public
    func encode(to _:inout BSON.FieldEncoder)
    {
    }
}
