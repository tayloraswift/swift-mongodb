extension BSON.Fields
{
    /// Creates a document containing the given fields.
    /// The order of the fields will be preserved.
    @inlinable public
    init(_ fields:some Collection<(key:String, value:AnyBSON<some RandomAccessCollection<UInt8>>)>)
    {
        self.init(output: .init(fields: fields))
    }
}
extension BSON.Fields:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(String, AnyBSON<[UInt8]>)...)
    {
        self.init(dictionaryLiteral)
    }
}
