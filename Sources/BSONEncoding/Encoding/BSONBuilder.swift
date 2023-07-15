public
protocol BSONBuilder<CodingKey>
{
    associatedtype CodingKey

    mutating
    func append(_ key:CodingKey, with encode:(inout BSON.Field) -> ())
}
extension BSONBuilder
{
    @inlinable public mutating
    func append(_ key:CodingKey, _ value:some BSONEncodable)
    {
        self.append(key, with: value.encode(to:))
    }
    @inlinable public mutating
    func push(_ key:CodingKey, _ value:(some BSONEncodable)?)
    {
        value.map
        {
            self.append(key, $0)
        }
    }
    @available(*, deprecated, message: "use append(_:_:) for non-optional values")
    public mutating
    func push(_ key:CodingKey, _ value:some BSONEncodable)
    {
        self.push(key, value as _?)
    }
}
extension BSONBuilder
{
    @inlinable public
    subscript(key:CodingKey, with encode:(inout BSON.ListEncoder) -> ()) -> Void
    {
        mutating get
        {
            self.append(key) { encode(&$0[as: BSON.ListEncoder.self]) }
        }
    }
    @inlinable public
    subscript(key:CodingKey,
        with encode:(inout BSON.DocumentEncoder<BSON.Key>) -> ()) -> Void
    {
        mutating get
        {
            self.append(key) { encode(&$0[as: BSON.DocumentEncoder<BSON.Key>.self]) }
        }
    }
    @inlinable public
    subscript<NestedKey>(key:CodingKey,
        using _:NestedKey.Type = NestedKey.self,
        with encode:(inout BSON.DocumentEncoder<NestedKey>) -> ()) -> Void
    {
        mutating get
        {
            self.append(key) { encode(&$0[as: BSON.DocumentEncoder<NestedKey>.self]) }
        }
    }
}

extension BSONBuilder
{
    /// Appends the given key-value pair to this document builder, encoding the
    /// value as the field value using its ``BSONEncodable`` implementation.
    ///
    /// Type inference will always prefer one of the concretely-typed subscript
    /// overloads over this one.
    ///
    /// The getter always returns [`nil`]().
    ///
    /// Every non-[`nil`]() assignment to this subscript (including mutations
    /// that leave the value in a non-[`nil`]() state after returning) will add
    /// a new field to the document, even if the key is the same.
    @inlinable public
    subscript<Value>(key:CodingKey) -> Value? where Value:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.push(key, value)
        }
    }
}
