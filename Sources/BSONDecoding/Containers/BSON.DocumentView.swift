import BSONUnions

extension BSON.DocumentView
{
    /// @import(BSONUnions)
    /// Decorates the ``AnyBSON``-yielding overload of this method with one that
    /// yields the key-value pairs as fields.
    @inlinable public
    func parse(
        to decode:(_ field:BSON.ExplicitField<String, Bytes.SubSequence>) throws -> ()) throws
    {
        try self.parse
        {
            try decode(.init(key: $0, value: $1))
        }
    }
}
