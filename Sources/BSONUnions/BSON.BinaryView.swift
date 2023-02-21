import BSON

extension BSON.BinaryView:BSONView
{
    @inlinable public
    init(_ value:AnyBSON<Bytes>) throws
    {
        self = try value.cast(with: \.binary)
    }
}
