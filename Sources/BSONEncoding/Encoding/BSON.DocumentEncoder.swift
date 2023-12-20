extension BSON
{
    @frozen public
    struct DocumentEncoder<CodingKey> where CodingKey:RawRepresentable<String>
    {
        @usableFromInline internal
        var output:BSON.Output<[UInt8]>

        @inlinable public
        init(_ output:BSON.Output<[UInt8]>)
        {
            self.output = output
        }
    }
}
extension BSON.DocumentEncoder:BSON.Encoder
{
    @inlinable public consuming
    func move() -> BSON.Output<[UInt8]> { self.output }

    @inlinable public static
    var type:BSON.AnyType { .document }
}
extension BSON.DocumentEncoder
{
    @inlinable public
    subscript(with key:some RawRepresentable<String>) -> BSON.FieldEncoder
    {
        _read
        {
            yield  self.output[with: .init(key)]
        }
        _modify
        {
            yield &self.output[with: .init(key)]
        }
    }
}
extension BSON.DocumentEncoder
{
    @inlinable public
    subscript(key:CodingKey, yield:(inout BSON.ListEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self[with: key][as: BSON.ListEncoder.self])
        }
    }
    @inlinable public
    subscript(key:CodingKey, yield:(inout BSON.DocumentEncoder<BSON.Key>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self[with: key][as: BSON.DocumentEncoder<BSON.Key>.self])
        }
    }
    @inlinable public
    subscript<NestedKey>(key:CodingKey,
        _:NestedKey.Type = NestedKey.self,
        yield:(inout BSON.DocumentEncoder<NestedKey>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self[with: key][as: BSON.DocumentEncoder<NestedKey>.self])
        }
    }
}
extension BSON.DocumentEncoder
{
    /// Appends the given key-value pair to this document builder, encoding the
    /// value as the field value using its ``BSONEncodable`` implementation.
    ///
    /// Type inference will always prefer one of the concretely-typed subscript
    /// overloads over this one.
    ///
    /// The getter always returns nil.
    ///
    /// Every non-nil assignment to this subscript (including mutations
    /// that leave the value in a non-nil state after returning) will add
    /// a new field to the document, even if the key is the same.
    @inlinable public
    subscript<Value>(key:CodingKey) -> Value? where Value:BSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self[with: key]) }
    }
}
