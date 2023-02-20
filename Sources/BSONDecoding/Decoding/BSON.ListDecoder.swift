import BSONUnions

extension BSON
{
    /// A thin wrapper around a native Swift array providing an efficient decoding
    /// interface for a ``BSON/ListView``.
    @frozen public
    struct ListDecoder<Storage> where Storage:RandomAccessCollection<UInt8>
    {
        public
        var elements:[AnyBSON<Bytes>]

        @inlinable public
        init(_ elements:[AnyBSON<Bytes>])
        {
            self.elements = elements
        }
    }
}
extension BSON.ListDecoder
{
    /// List decoder elements are indices over fragments of BSON
    /// parsed from a larger allocation, like ``Substring``s from a
    /// larger parent ``String``.
    public
    typealias Bytes = Storage.SubSequence

    /// Attempts to create a list decoder from the given list.
    ///
    /// To get a plain array with no decoding interface, call the list’s ``parse``
    /// method instead. Alternatively, you can use this function and access the
    /// ``elements`` property afterwards.
    ///
    /// >   Complexity: 
    //      O(*n*), where *n* is the number of elements in the source list.
    @inlinable public
    init(parsing bson:__shared BSON.ListView<Storage>) throws
    {
        self.init(try bson.parse())
    }
    /// Attempts to unwrap and parse an array-decoder from the given variant.
    ///
    /// This method will only attempt to parse statically-typed BSON lists; it will not
    /// inspect general documents to determine if they are valid lists.
    /// 
    /// -   Returns:
    ///     The payload of the variant, parsed to a list decoder, if it matches
    ///     ``case list(_:)`` and could be successfully parsed, [`nil`]() otherwise.
    ///
    /// >   Complexity: 
    //      O(*n*), where *n* is the number of elements in the source list.
    @inlinable public
    init(parsing bson:__shared AnyBSON<Storage>) throws
    {
        try self.init(parsing: try .init(bson))
    }

    /// The shape of the list being decoded.
    @inlinable public
    var shape:BSON.ListShape
    {
        .init(count: self.elements.count)
    }
}
extension BSON.ListDecoder:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.elements.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.elements.endIndex
    }
    @inlinable public
    subscript(index:Int) -> BSON.ExplicitField<Int, Bytes>
    {
        .init(key: index, value: self.elements[index])
    }
}
