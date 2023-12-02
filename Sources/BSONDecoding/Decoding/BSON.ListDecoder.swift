extension BSON
{
    /// A thin wrapper around a native Swift array providing an efficient decoding
    /// interface for a ``BSON/ListView``.
    @frozen public
    struct ListDecoder<Storage> where Storage:RandomAccessCollection<UInt8>
    {
        public
        var elements:[BSON.AnyValue<Bytes>]

        @inlinable public
        init(_ elements:[BSON.AnyValue<Bytes>])
        {
            self.elements = elements
        }
    }
}
extension BSON.ListDecoder:BSON.Decoder
{
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
    init(parsing bson:__shared BSON.AnyValue<Storage>) throws
    {
        try self.init(parsing: try .init(bson))
    }
}
extension BSON.ListDecoder
{
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

    /// The shape of the list being decoded.
    @inlinable public
    var shape:BSON.Shape
    {
        .init(length: self.elements.count)
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
    subscript(index:Int) -> BSON.FieldDecoder<Int, Bytes>
    {
        .init(key: index, value: self.elements[index])
    }
}
