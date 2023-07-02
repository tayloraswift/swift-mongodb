extension BSON.Decimal128:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(decimal128: self)
    }
}
