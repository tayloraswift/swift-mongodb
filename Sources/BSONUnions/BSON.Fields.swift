import BSON

extension BSON.Fields:ExpressibleByDictionaryLiteral
{
    /// Creates a document containing the given fields.
    /// The order of the fields will be preserved.
    @inlinable public
    init(dictionaryLiteral:(String, AnyBSON<[UInt8]>)...)
    {
        self.init(.init(fields: dictionaryLiteral))
    }
}
