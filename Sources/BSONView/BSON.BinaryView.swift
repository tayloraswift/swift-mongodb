import BSON

extension BSON.BinaryView:BSONView
{
    @inlinable public
    init(_ value:BSON.AnyValue<Bytes>) throws
    {
        self = try value.cast(with: \.binary)
    }
}
