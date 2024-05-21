extension BSON
{
    @frozen public
    struct Output:Sendable
    {
        public
        var destination:ArraySlice<UInt8>

        /// Create an output with a pre-allocated destination buffer. The buffer
        /// does *not* need to be empty, and existing data will not be cleared.
        @inlinable public
        init(preallocated destination:ArraySlice<UInt8>)
        {
            self.destination = destination
        }

        /// Create an empty output, reserving enough space for the specified
        /// number of bytes in the destination buffer.
        ///
        /// The size hint is only effective if `Destination` provides a real,
        /// non-defaulted witness for
        /// ``RangeReplaceableCollection.reserveCapacity(_:) [2YKV1]``.
        @inlinable public
        init(capacity:Int)
        {
            self.destination = .init()
            self.destination.reserveCapacity(capacity)
        }
    }
}
extension BSON.Output:BSON.OutputStream
{
    /// Reserves another `bytes` worth of capacity in the output destination, in addition to the
    /// bytes already present.
    @inlinable public mutating
    func reserve(another bytes:Int)
    {
        self.destination.reserveCapacity(self.destination.count + bytes)
    }

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
    func serialize(type:BSON.AnyType)
    {
        self.append(type.rawValue)
    }

    @inlinable public mutating
    func serialize(id:BSON.Identifier)
    {
        withUnsafeBytes(of: id.bitPattern)
        {
            self.append($0)
        }
    }
}
extension BSON.Output
{
    /// Serializes the given variant value, without encoding its type.
    @inlinable public mutating
    func serialize(variant:BSON.AnyValue)
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

        case .timestamp(let timestamp):
            self.serialize(integer: timestamp.value)

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
    func serialize(key:BSON.Key, value:BSON.AnyValue)
    {
        self.serialize(type: value.type)
        self.serialize(cString: key.rawValue)
        self.serialize(variant: value)
    }
    @inlinable public mutating
    func serialize(fields:some Sequence<(key:BSON.Key, value:BSON.AnyValue)>)
    {
        for (key, value):(BSON.Key, BSON.AnyValue) in fields
        {
            self.serialize(key: key, value: value)
        }
    }
}
extension BSON.Output
{
    /// Temporarily rebinds this output’s storage buffer to a field encoder. Field encoding is
    /// always lazy, so the getter has no effects.
    @inlinable public
    subscript(with key:BSON.Key) -> BSON.FieldEncoder
    {
        get
        {
            .init(key: key, output: self)
        }
        _modify
        {
            var field:BSON.FieldEncoder = self[with: key]
            self = .init(preallocated: [])
            defer { self = field.output }
            yield &field
        }
    }
}
extension BSON.Output
{
    /// Temporarily rebinds this output’s storage buffer to an encoder of the specified type,
    /// bracketing it with the appropriate headers or trailers.
    ///
    /// -   See also: ``subscript(as:)``.
    @inlinable public
    subscript<Encoder>(as _:Encoder.Type, in frame:BSON.DocumentFrame.Type) -> Encoder
        where Encoder:BSON.Encoder
    {
        mutating _read
        {
            yield  self[in: frame][as: Encoder.self]
        }
        _modify
        {
            yield &self[in: frame][as: Encoder.self]
        }
    }
    /// Temporarily rebinds this output’s storage buffer to an encoder of the specified type.
    /// This function does not add any headers or trailers; to emit a complete BSON frame,
    /// mutate through ``subscript(as:in:)``.
    ///
    /// Some encoders may write on ``BSON.Encoder/init(_:)`` to preserve application-level
    /// invariants, so type rebinding can have mutating effects even if the coroutine performs
    /// no writes.
    ///
    /// -   See also: ``subscript(with:)``.
    @inlinable public
    subscript<Encoder>(as _:Encoder.Type) -> Encoder where Encoder:BSON.Encoder
    {
        mutating _read
        {
            let encoder:Encoder = .init(consume self)
            defer { self = encoder.move() }
            yield encoder
        }
        _modify
        {
            var encoder:Encoder = .init(consume self)
            defer { self = encoder.move() }
            yield &encoder
        }
    }

    @inlinable
    subscript(in frame:(some BSON.BufferFrame).Type) -> Self
    {
        mutating _read
        {
            let header:Int = self.destination.endIndex

            self.append(0x00)
            self.append(0x00)
            self.append(0x00)
            self.append(0x00)

            defer
            {
                let written:Int

                if  let trailer:UInt8 = frame.trailer
                {
                    self.append(trailer)
                    written = 1
                }
                else
                {
                    written = 0
                }

                self.update(length: written - frame.skipped - 4, at: header)
            }

            yield self
        }

        _modify
        {
            let header:Int = self.destination.endIndex

            // make room for the length header
            self.append(0x00)
            self.append(0x00)
            self.append(0x00)
            self.append(0x00)

            defer
            {
                /// Make sure the caller has not cleared the buffer.
                assert(self.destination.index(header, offsetBy: 4) <= self.destination.endIndex)

                if  let trailer:UInt8 = frame.trailer
                {
                    self.append(trailer)
                }

                let written:Int = self.destination.distance(from: header,
                    to: self.destination.endIndex)

                self.update(length: written - frame.skipped - 4, at: header)
            }

            yield &self
        }
    }
}
extension BSON.Output
{
    /// Updates the length header at the specified `header` position to contain the given
    /// `length` value, encoding it to the output stream in little-endian byte order.
    @inlinable mutating
    func update(length:Int, at header:Int)
    {
        withUnsafeBytes(of: Int32.init(length).littleEndian)
        {
            var index:Int = header
            for byte:UInt8 in $0
            {
                self.destination[index] = byte
                self.destination.formIndex(after: &index)
            }
        }
    }
}
