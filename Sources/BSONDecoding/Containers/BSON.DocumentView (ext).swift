extension BSON.DocumentView
{
    /// @import(BSONView)
    /// Decorates the ``BSON.AnyValue``-yielding overload of this method with one that
    /// yields the key-value pairs as fields.
    @inlinable public
    func parse(
        to decode:(_ field:BSON.ExplicitField<BSON.Key, Bytes.SubSequence>) throws -> ()) throws
    {
        try self.parse
        {
            try decode(.init(key: $0, value: $1))
        }
    }
}
