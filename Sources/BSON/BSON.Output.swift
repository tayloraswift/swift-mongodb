import BSONTraversal

extension BSON
{
    @frozen public
    struct Output<Destination> where Destination:RangeReplaceableCollection<UInt8>
    {
        public
        var destination:Destination

        /// Create an output with a pre-allocated destination buffer. The buffer
        /// does *not* need to be empty, and existing data will not be cleared.
        @inlinable public
        init(preallocated destination:Destination)
        {
            self.destination = destination
        }

        /// Create an empty output, reserving enough space for the specified
        /// number of bytes in the destination buffer.
        ///
        /// The size hint is only effective if `Destination` provides a real,
        /// non-defaulted witness for ``RangeReplaceableCollection.reserveCapacity(_:)``.
        @inlinable public
        init(capacity:Int)
        {
            self.destination = .init()
            self.destination.reserveCapacity(capacity)
        }
    }
}
extension BSON.Output:Sendable where Destination:Sendable
{
}
extension BSON.Output
{
    /// Appends a single byte to the output destination.
    @inlinable public mutating
    func append(_ byte:UInt8)
    {
        self.destination.append(byte)
    }
    /// Appends a sequence of bytes to the output destination.
    @inlinable public mutating
    func append(_ bytes:some Sequence<UInt8>)
    {
        self.destination.append(contentsOf: bytes)
    }
}
extension BSON.Output
{
    @inlinable public mutating
    func serialize(type:BSON)
    {
        self.append(type.rawValue)
    }
    /// Serializes the UTF-8 code units of a string as a c-string with a trailing
    /// null byte. The `cString` must not contain null bytes. Use ``serialize(utf8:)`` 
    /// to serialize a string that contains interior null bytes.
    @inlinable public mutating
    func serialize(key:String)
    {
        self.append(key.utf8)
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
    func serialize(id:BSON.Identifier)
    {
        withUnsafeBytes(of: id.bitPattern)
        {
            self.append($0)
        }
    }
    @inlinable public mutating
    func serialize(utf8:BSON.UTF8<some BidirectionalCollection<UInt8>>)
    {
        self.serialize(integer: utf8.header)
        self.append(utf8.bytes)
        self.append(0x00)
    }
    @inlinable public mutating
    func serialize(binary:BSON.Binary<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(integer: binary.header)
        self.append(binary.subtype.rawValue)
        self.append(binary.bytes)
    }
    @inlinable public mutating
    func serialize(document:BSON.Document<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(integer: document.header)
        self.append(document.bytes)
        self.append(0x00)
    }
    @inlinable public mutating
    func serialize(tuple:BSON.Tuple<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(integer: tuple.header)
        self.append(tuple.bytes)
        self.append(0x00)
    }
}
extension BSON.Output<[UInt8]>
{
    @inlinable public mutating
    func with(key:String, do serialize:(inout BSON.Field) -> ())
    {
        var field:BSON.Field = .init(key: key, output: self)
        self = .init(preallocated: [])
        serialize(&field)
        self = field.output
    }
}
