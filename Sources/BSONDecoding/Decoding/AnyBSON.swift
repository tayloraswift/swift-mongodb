import BSONUnions

extension AnyBSON
{
    /// Attempts to unwrap and parse an array-decoder from this variant.
    ///
    /// This method will only attempt to parse statically-typed BSON tuples; it will not
    /// inspect general documents to determine if they are valid tuples.
    /// 
    /// -   Returns:
    ///     The payload of this variant, parsed to an array-decoder, if it matches
    ///     ``case tuple(_:)`` and could be successfully parsed, [`nil`]() otherwise.
    ///
    /// This method dispatches to ``BSON/Tuple.array``.
    ///
    /// >   Complexity: 
    //      O(*n*), where *n* is the number of elements in the source tuple.
    @inlinable public 
    func array() throws -> BSON.Array<Bytes.SubSequence>
    {
        try BSON.Tuple<Bytes>.init(self).array()
    }
    /// Attempts to unwrap and parse a fixed-length array-decoder from this variant.
    /// 
    /// -   Returns:
    ///     The payload of this variant, parsed to an array-decoder, if it matches
    ///     ``case tuple(_:)``, could be successfully parsed, and contains the
    ///     expected number of elements.
    ///
    /// >   Throws:
    ///     An ``ArrayShapeError`` if an array was successfully unwrapped and 
    ///     parsed, but it did not contain the expected number of elements.
    @inlinable public 
    func array(count:Int) throws -> BSON.Array<Bytes.SubSequence>
    {
        let array:BSON.Array<Bytes.SubSequence> = try self.array()
        if  array.count == count 
        {
            return array
        }
        else 
        {
            throw BSON.ArrayShapeError.init(invalid: array.count, expected: count)
        }
    }

    /// Attempts to unwrap and parse an array-decoder from this variant, whose length 
    /// satifies the given criteria.
    /// 
    /// -   Returns:
    ///     The payload of this variant if it matches ``case tuple(_:)``, could be
    ///     successfully parsed, and contains the expected number of elements.
    ///
    /// >   Throws:
    ///     An ``ArrayShapeError`` if an array was successfully unwrapped and 
    ///     parsed, but it did not contain the expected number of elements.
    @inlinable public 
    func array(
        where predicate:(_ count:Int) throws -> Bool) throws -> BSON.Array<Bytes.SubSequence>
    {
        let array:BSON.Array<Bytes.SubSequence> = try self.array()
        if try predicate(array.count)
        {
            return array
        }
        else 
        {
            throw BSON.ArrayShapeError.init(invalid: array.count)
        }
    }
}
extension AnyBSON
{
    /// Attempts to load a dictionary-decoder from this variant.
    /// 
    /// - Returns: A dictionary-decoder derived from the payload of this variant if it 
    ///     matches ``case document(_:)`` or ``case tuple(_:)``, [`nil`]() otherwise.
    ///
    /// This method dispatches to ``BSON/Document.dictionary``.
    @inlinable public 
    func dictionary() throws -> BSON.Dictionary<Bytes.SubSequence>
    {
        try BSON.Document<Bytes>.init(self).dictionary()
    }
}
