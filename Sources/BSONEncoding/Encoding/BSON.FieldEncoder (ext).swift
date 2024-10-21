extension BSON.FieldEncoder
{
    /// A shorthand for binding this field encoder to a ``DocumentEncoder``.
    @inlinable public mutating
    func callAsFunction<CodingKey>(_:CodingKey.Type,
        yield:(inout BSON.DocumentEncoder<CodingKey>) -> ()) -> Void
    {
        yield(&self[as: BSON.DocumentEncoder<CodingKey>.self])
    }
    /// A shorthand for binding this field encoder to a ``ListEncoder``.
    @inlinable public mutating
    func callAsFunction(_:Int.Type,
        yield:(inout BSON.ListEncoder) -> ()) -> Void
    {
        yield(&self[as: BSON.ListEncoder.self])
    }
}
