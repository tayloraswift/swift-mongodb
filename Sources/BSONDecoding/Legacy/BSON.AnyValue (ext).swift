extension BSON.AnyValue:Decoder
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
    func singleValueContainer() -> any SingleValueDecodingContainer
    {
        BSON.SingleValueDecoder<Bytes>.init(self, path: []) as any SingleValueDecodingContainer
    }
    @inlinable public
    func unkeyedContainer() throws -> any UnkeyedDecodingContainer
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
