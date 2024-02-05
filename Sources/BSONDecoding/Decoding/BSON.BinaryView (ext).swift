extension BSON.BinaryView
{
    @inlinable public
    var shape:BSON.Shape { .init(length: self.bytes.count) }
}
extension BSON.BinaryView<ArraySlice<UInt8>>:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self = try bson.cast(with: \.binary)
    }
}
