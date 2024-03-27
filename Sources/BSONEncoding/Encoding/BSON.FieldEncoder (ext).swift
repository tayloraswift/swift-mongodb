extension BSON.FieldEncoder
{
    /// A shorthand for binding this field encoder to a ``DocumentEncoder``.
    @inlinable public mutating
    func callAsFunction<CodingKey>(_:CodingKey.Type,
        yield:(inout BSON.DocumentEncoder<CodingKey>) -> ()) -> Void
    {
        yield(&self[as: BSON.DocumentEncoder<CodingKey>.self])
    }
}
