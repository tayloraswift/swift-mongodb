extension String:BSONStringDecodable
{
    /// Copies and validates the backing storage of the given UTF-8 string to a native Swift
    /// string, repairing invalid code units if needed.
    ///
    /// To convert a UTF-8 string backed by something that is not ``ArraySlice``, use
    /// ``BSON.UTF8View.description`` instead.
    ///
    /// >   Complexity: O(*n*), where *n* is the length of the string.
    @inlinable public
    init(bson:BSON.UTF8View<ArraySlice<UInt8>>)
    {
        self.init(decoding: bson.bytes, as: Unicode.UTF8.self)
    }
}
