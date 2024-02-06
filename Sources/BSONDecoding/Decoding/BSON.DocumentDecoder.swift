extension BSON
{
    /// A thin wrapper around a native Swift dictionary providing an efficient decoding
    /// interface for a ``BSON/DocumentView``.
    @frozen public
    struct DocumentDecoder<CodingKey>
        where   CodingKey:RawRepresentable<String>,
                CodingKey:Hashable,
                CodingKey:Sendable
    {
        @usableFromInline
        var index:[CodingKey: BSON.AnyValue]

        @inlinable public
        init(_ index:[CodingKey: BSON.AnyValue] = [:])
        {
            self.index = index
        }
    }
}
extension BSON.DocumentDecoder:BSON.Decoder
{
    /// Attempts to load a document decoder from the given variant.
    ///
    /// - Returns:
    ///     A document decoder derived from the payload of this variant if it matches
    ///     ``document(_:)`` **or** ``list(_:)``, nil otherwise.
    @inlinable public
    init(parsing bson:borrowing BSON.AnyValue) throws
    {
        try self.init(parsing: try .init(bson: copy bson))
    }
}
extension BSON.DocumentDecoder
{
    /// Attempts to create a decoder with typed coding keys from this document.
    ///
    /// This function will ignore fields whose keys do not correspond to valid
    /// instances of `CodingKey`. It will throw a ``DocumentKeyError`` if more
    /// than one non-ignored document field contains the same key.
    ///
    /// If `CodingKey` is ``Key``, this function will never ignore fields.
    ///
    /// Key duplication can interact with unicode normalization in unexpected
    /// ways. Because BSON is defined in UTF-8, other BSON encoders may not align
    /// with the behavior of ``String.==(_:_:)``, since that operator
    /// compares grapheme clusters and not UTF-8 code units.
    ///
    /// For example, if a document vends separate keys for [`"\u{E9}"`]() ([`"é"`]()) and
    /// [`"\u{65}\u{301}"`]() (also [`"é"`](), perhaps, because the document is
    /// being used to bootstrap a unicode table), uniquing them by ``String``
    /// comparison would drop one of the values.
    ///
    /// To get a plain array of key-value pairs with no decoding interface, call the
    /// document view’s ``BSON.Document/parse()`` method instead.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the number of fields in the source document.
    ///
    /// >   Warning:
    ///     When you convert an object to a dictionary representation, you lose the ordering
    ///     information for the object items. Re-encoding it may produce a BSON
    ///     document that contains the same data, but does not compare equal.
    @inlinable public
    init(parsing bson:borrowing BSON.Document) throws
    {
        self.init()
        try bson.parse
        {
            if case _? = self.index.updateValue($1, forKey: $0)
            {
                throw BSON.DocumentKeyError<CodingKey>.duplicate($0)
            }
        }
    }
}
extension BSON.DocumentDecoder:Sequence
{
    @inlinable public
    func makeIterator() -> Iterator
    {
        .init(base: self.index.makeIterator())
    }
}
extension BSON.DocumentDecoder
{
    @inlinable public consuming
    func single() throws -> BSON.FieldDecoder<CodingKey>
    {
        var single:BSON.FieldDecoder<CodingKey>? = nil
        for field:BSON.FieldDecoder<CodingKey> in self
        {
            if case nil = single
            {
                single = field
            }
            else
            {
                throw BSON.SingleKeyError<CodingKey>.multiple
            }
        }
        guard let single
        else
        {
            throw BSON.SingleKeyError<CodingKey>.none
        }
        return single
    }

    @inlinable public
    subscript(key:CodingKey) -> BSON.OptionalDecoder<CodingKey>
    {
        .init(key: key, value: self.index[key])
    }
    @inlinable public
    subscript(key:CodingKey) -> BSON.FieldDecoder<CodingKey>?
    {
        self.index[key].map { .init(key: key, value: $0) }
    }
}
