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
    func decoder() throws -> BSON.ListDecoder<Bytes.SubSequence>
    {
        try BSON.ListView<Bytes>.init(self).decoder()
    }
}
extension AnyBSON
{
    /// Attempts to load a document decoder from this variant.
    /// 
    /// - Returns: A document decoder derived from the payload of this variant if it 
    ///     matches ``case document(_:)`` or ``case list(_:)``, [`nil`]() otherwise.
    ///
    /// This method dispatches to ``BSON.DocumentView.dictionary``.
    @inlinable public 
    func decoder(keys _:String.Type = String.self)
        throws -> BSON.DocumentDecoder<String, Bytes.SubSequence>
    {
        try BSON.DocumentView<Bytes>.init(self).decoder()
    }
    @inlinable public 
    func decoder<CodingKey>(keys _:CodingKey.Type = CodingKey.self)
        throws -> BSON.DocumentDecoder<CodingKey, Bytes.SubSequence>
        where CodingKey:Hashable & RawRepresentable<String>
    {
        try BSON.DocumentView<Bytes>.init(self).decoder()
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
