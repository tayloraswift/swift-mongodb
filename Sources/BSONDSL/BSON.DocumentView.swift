import BSON

extension BSON.DocumentView<[UInt8]>
{
    /// Stores the output buffer of the given document into
    /// an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ document:some BSONDSL)
    {
        self.init(slice: document.bytes)
    }
}
