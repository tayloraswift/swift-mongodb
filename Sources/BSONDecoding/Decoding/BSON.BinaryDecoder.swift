extension BSON
{
    @frozen public
    struct BinaryDecoder
    {
        @usableFromInline
        let view:BSON.BinaryView<ArraySlice<UInt8>>

        @inlinable
        init(view:BSON.BinaryView<ArraySlice<UInt8>>)
        {
            self.view = view
        }
    }
}
extension BSON.BinaryDecoder:BSON.Decoder
{
    /// Attempts to unwrap a binary array from the given variant. Despite the name, this
    /// initializer performs no actual parsing.
    @inlinable public
    init(parsing bson:borrowing BSON.AnyValue) throws
    {
        self.init(view: try .init(bson: copy bson))
    }
}
extension BSON.BinaryDecoder
{
    @inlinable public
    var bytes:ArraySlice<UInt8> { self.view.bytes }

    @inlinable public
    var shape:BSON.Shape { .init(length: self.view.bytes.count) }

    @inlinable public
    var subtype:BSON.BinarySubtype { self.view.subtype }
}
