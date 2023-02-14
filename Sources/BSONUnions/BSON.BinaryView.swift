import BSON

extension BSON.BinaryView
{
    @inlinable public
    init(_ value:AnyBSON<Bytes>) throws
    {
        self = try value.cast(with: \.binary)
    }
}
