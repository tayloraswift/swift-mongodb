import BSON

extension BSON.Binary
{
    @inlinable public
    init(_ value:AnyBSON<Bytes>) throws
    {
        self = try value.cast(with: \.binary)
    }
}
