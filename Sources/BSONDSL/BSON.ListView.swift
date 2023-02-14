import BSON

extension BSON.ListView<[UInt8]>
{
    /// Stores the output buffer of the given list elements into
    /// an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ elements:BSON.Elements<some Any>)
    {
        self.init(slice: elements.bytes)
    }
}
