public
protocol BSONBinaryEncodable:BSONEncodable
{
    /// Populates a binary array from this instance by encoding to the parameter, possibly
    /// updating the array’s binary ``BSON.BinaryEncoder/subtype`` as well.
    ///
    /// The implementation must not assume the encoding container is initially empty, because it
    /// may be the owner of the final output buffer.
    func encode(to bson:inout BSON.BinaryEncoder)
}
extension BSONBinaryEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.encode(to: &field[as: BSON.BinaryEncoder.self])
    }
}
