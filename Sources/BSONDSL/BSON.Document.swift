import BSON

extension BSON.Document<[UInt8]>
{
    /// Stores the output buffer of the given document fields into
    /// an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ fields:some BSONDSL)
    {
        self.init(slice: fields.bytes)
    }
}
