extension BSON.DocumentDecoder
{
    @frozen public
    struct Iterator
    {
        @usableFromInline internal
        var base:Dictionary<CodingKey, BSON.AnyValue<Bytes>>.Iterator

        @inlinable internal
        init(base:Dictionary<CodingKey, BSON.AnyValue<Bytes>>.Iterator)
        {
            self.base = base
        }
    }
}
extension BSON.DocumentDecoder.Iterator:IteratorProtocol
{
    @inlinable public mutating
    func next() -> BSON.FieldDecoder<CodingKey, Storage.SubSequence>?
    {
        self.base.next().map { .init(key: $0.key, value: $0.value) }
    }
}
