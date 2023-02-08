import BSON

extension BSON.Tuple<[UInt8]>
{
    /// Stores the output buffer of the given tuple elements into
    /// an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ elements:BSON.Elements<some Any>)
    {
        self.init(slice: elements.bytes)
    }
}
