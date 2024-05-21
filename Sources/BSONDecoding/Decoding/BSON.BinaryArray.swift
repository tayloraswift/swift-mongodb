extension BSON
{
    /// A `BinaryArray` is a typed view of an ``ArraySlice`` as a densly-packed buffer of
    /// trivial `Element`s. It’s a good idea to use something unpretentious like a tuple of
    /// fixed-width integers for the `Element` type, to avoid unexpected padding behavior.
    ///
    /// In any large MongoDB deployment, you should assume that your schema will be loaded and
    /// saved from machines with different endianness.
    @frozen public
    struct BinaryArray<Element>
    {
        public
        let bytes:ArraySlice<UInt8>
        public
        let count:Int

        @inlinable
        init(bytes:ArraySlice<UInt8>, count:Int)
        {
            self.bytes = bytes
            self.count = count
        }
    }
}
extension BSON.BinaryArray:BSONBinaryDecodable
{
    @inlinable public
    init(bson:BSON.BinaryDecoder) throws
    {
        self.init(bytes: bson.bytes,
            count: try bson.shape.expect(multipleOf: MemoryLayout<Element>.size))
    }
}
extension BSON.BinaryArray:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { 0 }

    @inlinable public
    var endIndex:Int { self.count }

    @inlinable public
    subscript(position:Int) -> Element
    {
        precondition(self.indices ~= position, "Index out of bounds")

        return self.bytes.withUnsafeBytes
        {
            $0.loadUnaligned(fromByteOffset: position * MemoryLayout<Element>.size,
                as: Element.self)
        }
    }
}
