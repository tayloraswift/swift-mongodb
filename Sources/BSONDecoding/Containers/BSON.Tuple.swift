import BSONUnions

extension BSON.Tuple
{
    /// @import(BSONUnions)
    /// Decorates the ``AnyBSON``-yielding overload of this method with one that
    /// enumerates the elements and yields them as fields.
    @inlinable public
    func parse(
        to decode:(_ field:BSON.ExplicitField<Int, Bytes.SubSequence>) throws -> ()) throws
    {
        var index:Int = 0
        try self.parse
        {
            try decode(.init(key: index, value: $0))
            index += 1
        }
    }

    /// Attempts to create an array-decoder from this tuple.
    ///
    /// To get a plain array with no decoding interface, call the ``parse`` method.
    /// Alternatively, you can use this method and access the ``BSON//Array.elements``
    /// property.
    ///
    /// >   Complexity: 
    //      O(*n*), where *n* is the number of elements in the source tuple.
    @inlinable public 
    func array() throws -> BSON.Array<Bytes.SubSequence>
    {
        .init(try self.parse())
    }
}
