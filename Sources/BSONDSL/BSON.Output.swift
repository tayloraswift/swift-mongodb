import BSON
import BSONTraversal

extension BSON
{
    @frozen public
    struct Output<Destination>
        where   Destination.Index == Int,
                Destination:RangeReplaceableCollection<UInt8>,
                Destination:RandomAccessCollection<UInt8>
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
    func serialize(id:BSON.Identifier)
    {
        withUnsafeBytes(of: id.bitPattern)
        {
            self.append($0)
        }
    }
    @inlinable public mutating
    func serialize(utf8:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self.serialize(integer: utf8.header)
        self.append(utf8.slice)
        self.append(0x00)
    }
    @inlinable public mutating
    func serialize(binary:BSON.BinaryView<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(integer: binary.header)
        self.append(binary.subtype.rawValue)
        self.append(binary.slice)
    }
    @inlinable public mutating
    func serialize(document:BSON.DocumentView<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(integer: document.header)
        self.append(document.slice)
        self.append(0x00)
    }
    @inlinable public mutating
    func serialize(list:BSON.ListView<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(integer: list.header)
        self.append(list.slice)
        self.append(0x00)
    }
}
extension BSON.Output
{
    /// Serializes the given variant value, without encoding its type.
    @inlinable public mutating
    func serialize(variant:BSON.AnyValue<some RandomAccessCollection<UInt8>>)
    {
        switch variant
        {
        case .double(let double):
            self.serialize(integer: double.bitPattern)
        
        case .string(let string):
            self.serialize(utf8: string)
        
        case .document(let document):
            self.serialize(document: document)

        case .list(let list):
            self.serialize(list: list)

        case .binary(let binary):
            self.serialize(binary: binary)
        
        case .null:
            break
        
        case .id(let id):
            self.serialize(id: id)
        
        case .bool(let bool):
            self.append(bool ? 1 : 0)

        case .millisecond(let millisecond):
            self.serialize(integer: millisecond.value)
        
        case .regex(let regex):
            self.serialize(cString: regex.pattern)
            self.serialize(cString: regex.options.description)
        
        case .pointer(let database, let id):
            self.serialize(utf8: database)
            self.serialize(id: id)
        
        case .javascript(let code):
            self.serialize(utf8: code)
        
        case .javascriptScope(let scope, let code):
            let size:Int32 = 4 + Int32.init(scope.size) + Int32.init(code.size)
            self.serialize(integer: size)
            self.serialize(utf8: code)
            self.serialize(document: scope)
        
        case .int32(let int32):
            self.serialize(integer: int32)
        
        case .uint64(let uint64):
            self.serialize(integer: uint64)
        
        case .int64(let int64):
            self.serialize(integer: int64)

        case .decimal128(let decimal):
            self.serialize(integer: decimal.low)
            self.serialize(integer: decimal.high)
        
        case .max:
            break
        case .min:
            break
        }
    }
    /// Serializes the raw type code of the given variant value, followed by
    /// the field key (with a trailing null byte), followed by the variant value
    /// itself.
    @inlinable public mutating
    func serialize(key:BSON.Key, value:BSON.AnyValue<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(type: value.type)
        self.serialize(cString: key.rawValue)
        self.serialize(variant: value)
    }
    @inlinable public mutating
    func serialize<Bytes>(fields:some Sequence<(key:BSON.Key, value:BSON.AnyValue<Bytes>)>)
        where Bytes:RandomAccessCollection<UInt8>
    {
        for (key, value):(BSON.Key, BSON.AnyValue<Bytes>) in fields
        {
            self.serialize(key: key, value: value)
        }
    }
}
extension BSON.Output<[UInt8]>
{
    @inlinable public mutating
    func with(key:BSON.Key, do encode:(inout BSON.Field) -> ())
    {
        var field:BSON.Field = .init(key: key, output: self)
        self = .init(preallocated: [])
        encode(&field)
        self = field.output
    }
    @inlinable public mutating
    func with<Frame>(frame _:Frame.Type, do serialize:(inout Self) -> ())
        where Frame:VariableLengthBSONFrame
    {
        let start:Int = self.destination.endIndex

        // make room for the length header
        self.append(0x00)
        self.append(0x00)
        self.append(0x00)
        self.append(0x00)

        serialize(&self)

        assert(self.destination.index(start, offsetBy: 4) <= self.destination.endIndex)
        
        if let trailer:UInt8 = Frame.trailer
        {
            self.append(trailer)
        }

        let written:Int = self.destination.distance(from: start,
            to: self.destination.endIndex)

        let length:Int32 = .init(written - Frame.skipped - 4)

        withUnsafeBytes(of: length.littleEndian)
        {
            var index:Int = start
            for byte:UInt8 in $0
            {
                self.destination[index] = byte
                self.destination.formIndex(after: &index)
            }
        }
    }
}

