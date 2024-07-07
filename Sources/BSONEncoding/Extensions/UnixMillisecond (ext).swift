import UnixTime

extension UnixMillisecond:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(millisecond: self)
    }
}
