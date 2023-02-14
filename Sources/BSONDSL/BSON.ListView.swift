import BSON

extension BSON.ListView<[UInt8]>
{
    /// Stores the output buffer of the given list into
    /// an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ list:BSON.List<some Any>)
    {
        self.init(slice: list.bytes)
    }
}
