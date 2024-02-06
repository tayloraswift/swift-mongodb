extension BSON.Document:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        self = try bson.cast(with: \.document)
    }
}
extension BSON.Document
{
    /// Decorates the ``BSON.AnyValue``-yielding overload of this method with one that
    /// yields the key-value pairs as fields.
    @inlinable public
    func parse(to decode:(_ field:BSON.FieldDecoder<BSON.Key>) throws -> ()) throws
    {
        try self.parse
        {
            try decode(.init(key: $0, value: $1))
        }
    }
}
