extension Character:BSONStringDecodable
{
    /// Witnesses `Character`’s ``BSONStringDecodable`` conformance, throwing
    /// a ``BSON.ValueError`` instead of trapping on multi-character input.
    ///
    /// This is needed because its ``LosslessStringConvertible.init(_:)``
    /// witness traps on invalid input instead of returning nil, which causes
    /// its default implementation (where `Self` is ``LosslessStringConvertible``)
    /// to do the same.
    @inlinable public
    init(bson:BSON.UTF8View<ArraySlice<UInt8>>) throws
    {
        let string:String = .init(bson: bson)
        if  string.startIndex < string.endIndex,
            string.index(after: string.startIndex) == string.endIndex
        {
            self = string[string.startIndex]
        }
        else
        {
            throw BSON.ValueError<String, Self>.init(invalid: string)
        }
    }
}
