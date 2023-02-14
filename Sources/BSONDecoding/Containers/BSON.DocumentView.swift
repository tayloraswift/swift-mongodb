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

    /// Attempts to create a dictionary-decoder from this document.
    /// 
    /// This method will throw a ``BSON//DictionaryKeyError`` more than one document
    /// field contains a key with the same name.
    ///
    /// Key duplication can interact with unicode normalization in unexpected 
    /// ways. Because BSON is defined in UTF-8, other BSON encoders may not align 
    /// with the behavior of ``String.==(_:_:)``, since that operator 
    /// compares grapheme clusters and not UTF-8 code units. 
    /// 
    /// For example, if a document vends separate keys for [`"\u{E9}"`]() ([`"é"`]()) and 
    /// [`"\u{65}\u{301}"`]() (also [`"é"`](), perhaps, because the document is 
    /// being used to bootstrap a unicode table), uniquing them by ``String`` 
    /// comparison would drop one of the values.
    ///
    /// To get a plain array of key-value pairs with no decoding interface, cast this
    /// variant to a ``BSON/DocumentView`` and call its ``BSON/DocumentView/.parse()`` method.
    /// 
    /// >   Complexity: 
    ///     O(*n*), where *n* is the number of fields in the source document.
    ///
    /// >   Warning: 
    ///     When you convert an object to a dictionary representation, you lose the ordering 
    ///     information for the object items. Reencoding it may produce a BSON 
    ///     document that contains the same data, but does not compare equal.
    @inlinable public 
    func dictionary() throws -> BSON.Dictionary<Bytes.SubSequence>
    {
        var dictionary:BSON.Dictionary<Bytes.SubSequence> = .init()
        try self.parse
        {
            if case _? = dictionary.items.updateValue($1, forKey: $0)
            {
                throw BSON.DictionaryKeyError.duplicate($0)
            }
        }
        return dictionary
    }
}
