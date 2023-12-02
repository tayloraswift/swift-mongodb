extension BSON.Decimal128:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(decimal128: self)
    }
}
