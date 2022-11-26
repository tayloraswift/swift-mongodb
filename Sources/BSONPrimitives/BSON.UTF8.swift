extension BSON.UTF8:CollectionViewBSON where Bytes:RandomAccessCollection<UInt8>
{
    @inlinable public
    init(_ value:AnyBSON<Bytes>) throws
    {
        self = try value.cast(with: \.utf8)
    }
}
