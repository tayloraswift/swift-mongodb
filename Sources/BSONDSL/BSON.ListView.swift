import BSON

extension BSON.ListView<[UInt8]>
{
    /// Stores the output buffer of the given list into
    /// an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ list:BSON.List<some Any>)
    {
        self.init(slice: list.bytes)
    }
}
extension BSON.ListView:ExpressibleByArrayLiteral
    where   Bytes:RangeReplaceableCollection<UInt8>,
            Bytes:RandomAccessCollection<UInt8>,
            Bytes.Index == Int
{
    /// Creates a list-document containing the given elements.
    @inlinable public
    init(elements:some Sequence<BSON.AnyValue<some RandomAccessCollection<UInt8>>>)
    {
        // we do need to precompute the ordinal keys, so we know the total length
        // of the document.
        let document:BSON.DocumentView<Bytes> = .init(fields: elements.enumerated().map
        {
            (.init(index: $0.0), $0.1)
        })
        self.init(slice: document.slice)
    }

    @inlinable public 
    init(arrayLiteral:BSON.AnyValue<Bytes>...)
    {
        self.init(elements: arrayLiteral)
    }
}
