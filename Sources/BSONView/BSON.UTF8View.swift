import BSON

extension BSON.UTF8View:BSONView where Bytes:RandomAccessCollection<UInt8>
{
    @inlinable public
    init(_ value:BSON.AnyValue<Bytes>) throws
    {
        self = try value.cast(with: \.utf8)
    }
}
