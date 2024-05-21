extension BSON.BinaryView:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(binary: self)
    }
}

extension BSON.BinaryView<ArraySlice<UInt8>>
{
    @inlinable public
    init(with encode:(inout BSON.BinaryEncoder) throws -> ()) rethrows
    {
        /// The ``BinaryEncoder`` will always write a superfluous subtype byte, so we might as
        /// well preallocate the capacity for it.
        var output:BSON.Output = .init(capacity: 1)

        /// This shouldn’t copy, as ``BinaryEncoder.move`` does not write to the buffer.
        let (subtype, bytes):(BSON.BinarySubtype, ArraySlice<UInt8>) = try
        {
            try encode(&$0)
            return ($0.subtype, $0.bytes)
        } (&output[as: BSON.BinaryEncoder.self])

        self.init(subtype: subtype, bytes: bytes)
    }
}
