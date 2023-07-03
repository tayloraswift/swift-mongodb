extension BSON.Max:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}
