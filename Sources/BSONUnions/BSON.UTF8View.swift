import BSON

extension BSON.UTF8View:BSONView where Bytes:RandomAccessCollection<UInt8>
{
    @inlinable public
    init(_ value:AnyBSON<Bytes>) throws
    {
        self = try value.cast(with: \.utf8)
    }
}
