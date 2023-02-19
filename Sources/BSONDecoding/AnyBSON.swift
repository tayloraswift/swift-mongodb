import BSONUnions

extension AnyBSON
{
    /// Attempts to unwrap and parse an array-decoder from this variant.
    ///
    /// This method will only attempt to parse statically-typed BSON lists; it will not
    /// inspect general documents to determine if they are valid lists.
    /// 
    /// -   Returns:
    ///     The payload of this variant, parsed to an array-decoder, if it matches
    ///     ``case list(_:)`` and could be successfully parsed, [`nil`]() otherwise.
    ///
    /// This method dispatches to ``BSON/ListView.array``.
    ///
    /// >   Complexity: 
    //      O(*n*), where *n* is the number of elements in the source list.
    @inlinable public 
    func array() throws -> BSON.Array<Bytes.SubSequence>
    {
        try BSON.ListView<Bytes>.init(self).array()
    }
}
extension AnyBSON
{
    /// Attempts to load a dictionary-decoder from this variant.
    /// 
    /// - Returns: A dictionary-decoder derived from the payload of this variant if it 
    ///     matches ``case document(_:)`` or ``case list(_:)``, [`nil`]() otherwise.
    ///
    /// This method dispatches to ``BSON/DocumentView.dictionary``.
    @inlinable public 
    func dictionary() throws -> BSON.Dictionary<Bytes.SubSequence>
    {
        try BSON.DocumentView<Bytes>.init(self).dictionary()
    }
}

extension AnyBSON:Decoder 
{
    @inlinable public 
    var codingPath:[any CodingKey] 
    {
        []
    }
    @inlinable public 
    var userInfo:[CodingUserInfoKey: Any] 
    {
        [:]
    }

    @inlinable public 
    func singleValueContainer() -> SingleValueDecodingContainer
    {
        BSON.SingleValueDecoder<Bytes>.init(self, path: []) as SingleValueDecodingContainer
    }
    @inlinable public 
    func unkeyedContainer() throws -> UnkeyedDecodingContainer
    {
        try BSON.SingleValueDecoder<Bytes>.init(self, path: []).unkeyedContainer()
    }
    @inlinable public 
    func container<Key>(keyedBy _:Key.Type) throws -> KeyedDecodingContainer<Key> 
        where Key:CodingKey 
    {
        try BSON.SingleValueDecoder<Bytes>.init(self, path: []).container(keyedBy: Key.self)
    }
}
