extension Int:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.int32`` if it can be represented
    /// exactly, or ``BSON.int64`` otherwise.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        if  let int32:Int32 = .init(exactly: self)
        {
            field.encode(int32: int32)
        }
        else
        {
            field.encode(int64: .init(self))
        }
    }
}
