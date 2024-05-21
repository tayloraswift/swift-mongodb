extension BSON
{
    public
    protocol OutputStream
    {
        mutating
        func reserve(another bytes:Int)

        mutating
        func append(_ byte:UInt8)
        mutating
        func append(_ bytes:some Sequence<UInt8>)
    }
}
extension BSON.OutputStream
{
    /// Serializes the UTF-8 code units of a string as a c-string with a trailing
    /// null byte. The `cString` must not contain null bytes. Use ``serialize(utf8:)``
    /// to serialize a string that contains interior null bytes.
    @inlinable public mutating
    func serialize(cString:String)
    {
        self.append(cString.utf8)
        self.append(0x00)
    }
    /// Serializes a fixed-width integer in little-endian byte order.
    @inlinable public mutating
    func serialize(integer:some FixedWidthInteger)
    {
        withUnsafeBytes(of: integer.littleEndian)
        {
            self.append($0)
        }
    }

    @inlinable public mutating
    func serialize(utf8:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self.serialize(integer: utf8.header)
        self.append(utf8.bytes)
        self.append(0x00)
    }
    @inlinable public mutating
    func serialize(binary:BSON.BinaryView<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(integer: binary.header)
        self.append(binary.subtype.rawValue)
        self.append(binary.bytes)
    }
    @inlinable public mutating
    func serialize(document:BSON.Document)
    {
        self.serialize(integer: document.header)
        self.append(document.bytes)
        self.append(0x00)
    }
    @inlinable public mutating
    func serialize(list:BSON.List)
    {
        self.serialize(integer: list.header)
        self.append(list.bytes)
        self.append(0x00)
    }
}
