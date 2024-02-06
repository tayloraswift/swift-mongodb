extension BSON.UTF8View<ArraySlice<UInt8>>:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self = try bson.cast(with: \.utf8)
    }
}
