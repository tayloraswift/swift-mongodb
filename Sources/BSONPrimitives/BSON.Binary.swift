extension BSON.Binary:CollectionViewBSON
{
    @inlinable public
    init(_ value:AnyBSON<Bytes>) throws
    {
        self = try value.cast(with: \.binary)
    }
}
