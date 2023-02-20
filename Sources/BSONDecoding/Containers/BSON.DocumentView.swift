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

    /// Attempts to create a string-keyed decoder from this document.
    /// 
    /// This function will throw a ``DocumentKeyError`` if more than one document
    /// field contains a key with the same name. This function will never ignore
    /// fields.
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
    /// variant to a ``BSON.DocumentView`` and call its ``BSON.DocumentView parse()`` method.
    /// 
    /// >   Complexity: 
    ///     O(*n*), where *n* is the number of fields in the source document.
    ///
    /// >   Warning: 
    ///     When you convert an object to a dictionary representation, you lose the ordering 
    ///     information for the object items. Reencoding it may produce a BSON 
    ///     document that contains the same data, but does not compare equal.
    @inlinable public 
    func decoder()
        throws -> BSON.DocumentDecoder<String, Bytes.SubSequence>
    {
        var decoder:BSON.DocumentDecoder<String, Bytes.SubSequence> = .init()
        try self.parse
        {
            if case _? = decoder.index.updateValue($1, forKey: $0)
            {
                throw BSON.DocumentKeyError<String>.duplicate($0)
            }
        }
        return decoder
    }
    /// Attempts to create a decoder with typed coding keys from this document.
    /// 
    /// This function will ignore fields whose keys do not correspond to valid
    /// instances of `CodingKey`. It will throw a ``DocumentKeyError`` if more
    /// than one non-ignored document field contains the same key. 
    @inlinable public 
    func decoder<CodingKey>(keys _:CodingKey.Type = CodingKey.self)
        throws -> BSON.DocumentDecoder<CodingKey, Bytes.SubSequence>
        where CodingKey:Hashable & RawRepresentable<String>
    {
        var decoder:BSON.DocumentDecoder<CodingKey, Bytes.SubSequence> = .init()
        try self.parse
        {
            guard let key:CodingKey = .init(rawValue: $0)
            else
            {
                return
            }
            if case _? = decoder.index.updateValue($1, forKey: key)
            {
                throw BSON.DocumentKeyError<CodingKey>.duplicate(key)
            }
        }
        return decoder
    }
}
