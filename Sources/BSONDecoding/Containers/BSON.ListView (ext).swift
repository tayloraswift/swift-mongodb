extension BSON.ListView
{
    /// Decorates the ``BSON.AnyValue``-yielding overload of this method with one that
    /// enumerates the elements and yields them as fields.
    @inlinable public
    func parse(to decode:(_ field:BSON.FieldDecoder<Int>) throws -> ()) throws
    {
        var index:Int = 0
        try self.parse
        {
            try decode(.init(key: index, value: $0))
            index += 1
        }
    }
}
