extension BSON
{
    /// A MongoDB object reference. This type models a MongoDB `ObjectId`.
    ///
    /// This type has reference semantics, but (needless to say) it is
    /// completely unmanaged, as it is nothing more than a 96-bit integer.
    ///
    /// The type name is chosen to avoid conflict with Swift’s ``ObjectIdentifier``.
    @frozen public
    struct Identifier:Sendable
    {
        public
        let bitPattern:(UInt32, UInt32, UInt32)

        /// Creates an identifier with the given bit pattern. Do not use this
        /// initializer to create an identifier from integer literals; use
        /// ``init(_:_:_:)``, which accounts for platform endianness, instead.
        @inlinable internal
        init(bitPattern:(UInt32, UInt32, UInt32))
        {
            self.bitPattern = bitPattern
        }
    }
}
extension BSON.Identifier
{
    /// Creates an identifier with the given high-, middle-, and low-components.
    /// The components are interpreted by platform endianness; therefore the values
    /// stored into ``bitPattern`` may be different if the current host is not
    /// big-endian.
    @inlinable public
    init(_ high:UInt32, _ middle:UInt32, _ low:UInt32)
    {
        self.init(bitPattern: (high.bigEndian, middle.bigEndian, low.bigEndian))
    }
    /// Creates an identifier by delegating to the closure to initialize raw memory.
    /// The buffer contains 12 bytes and will be interpreted as a 96-bit, big-endian
    /// integer.
    @inlinable public
    init(with initialize:(_ memory:UnsafeMutableRawBufferPointer) throws -> ()) rethrows
    {
        let bitPattern:(UInt32, UInt32, UInt32) = try withUnsafeTemporaryAllocation(
            byteCount: MemoryLayout<(UInt32, UInt32, UInt32)>.size,
            alignment: MemoryLayout<(UInt32, UInt32, UInt32)>.alignment)
        {
            try initialize($0)
            return $0.load(as: (UInt32, UInt32, UInt32).self)
        }

        self.init(bitPattern: bitPattern)
    }
}
extension BSON.Identifier
{
    /// The high 32 bits of this identifier. The high byte of this
    /// integer is the byte at offset +0 of this identifier.
    @inlinable public
    var timestamp:UInt32
    {
        .init(bigEndian: self.bitPattern.0)
    }
    /// The middle 32 bits of this identifier. The high byte of this
    /// integer is the byte at offset +4 of this identifier.
    @inlinable public
    var middle:UInt32
    {
        .init(bigEndian: self.bitPattern.1)
    }
    /// The low 32 bits of this identifier. The high byte of this
    /// integer is the byte at offset +8 of this identifier.
    @inlinable public
    var low:UInt32
    {
        .init(bigEndian: self.bitPattern.2)
    }
}
extension BSON.Identifier:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:StaticBigInt)
    {
        precondition(integerLiteral.signum() >= 0,
            "BSON identifier literal cannot be negative")
        precondition(integerLiteral.bitWidth <= 97, // +1 bit for “sign” bit
            "BSON identifier literal overflows UInt96 (bit width: \(integerLiteral.bitWidth))")

        self.init
        {
            (bytes:UnsafeMutableRawBufferPointer) in

            var byte:Int = bytes.endIndex
            var word:Int = 0
            while byte != bytes.startIndex
            {
                withUnsafeBytes(of: integerLiteral[word].bigEndian)
                {
                    for value:UInt8 in $0.reversed()
                    {
                        byte = bytes.index(before: byte)
                        bytes[byte] = value

                        if  byte == bytes.startIndex
                        {
                            break
                        }
                    }
                }
                word += 1
            }
        }
    }
}
extension BSON.Identifier:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        let unpadded:(String, String, String) =
        (
            .init(self.timestamp, radix: 16),
            .init(self.middle, radix: 16),
            .init(self.low, radix: 16)
        )
        let padding:(String, String, String) =
        (
            "\(String.init(repeating: "0", count: 8 - unpadded.0.count))",
            "\(String.init(repeating: "0", count: 8 - unpadded.1.count))",
            "\(String.init(repeating: "0", count: 8 - unpadded.2.count))"
        )
        return "0x\(padding.0)\(unpadded.0)_\(padding.1)\(unpadded.1)_\(padding.2)\(unpadded.2)"
    }
}
extension BSON.Identifier
{
    public
    typealias Seed =
    (
        UInt8,
        UInt8,
        UInt8,
        UInt8,
        UInt8
    )
    public
    typealias Ordinal =
    (
        UInt8,
        UInt8,
        UInt8
    )

    @inlinable public
    init(timestamp:UInt32, seed:Seed, ordinal:Ordinal)
    {
        self.init(bitPattern:
        (
            timestamp.bigEndian,
            withUnsafeBytes(of: (seed.0,    seed.1,    seed.2,    seed.3))
            {
                $0.load(as: UInt32.self)
            },
            withUnsafeBytes(of: (seed.4, ordinal.0, ordinal.1, ordinal.2))
            {
                $0.load(as: UInt32.self)
            }
        ))
    }

    /// The middle five bytes of this identifier. The first tuple element
    /// is the byte at offset +4 of this identifier.
    @inlinable public
    var seed:Seed
    {
        withUnsafeBytes(of: self.bitPattern)
        {
            $0.load(fromByteOffset: 4, as: Seed.self)
        }
    }

    /// The last three bytes of this identifier. The first tuple element
    /// is the byte at offset +9 of this identifier.
    @inlinable public
    var ordinal:Ordinal
    {
        withUnsafeBytes(of: self.bitPattern)
        {
            $0.load(fromByteOffset: 9, as: Ordinal.self)
        }
    }
}
extension BSON.Identifier:Equatable
{
    @inlinable public static
    func == (lhs:Self, rhs:Self) -> Bool
    {
        lhs.bitPattern == rhs.bitPattern
    }
}
extension BSON.Identifier:Comparable
{
    /// Compares the bytes of this identifier in lexicographical order.
    /// This is the same as performing a lexicographic numeric comparison
    /// on (``timestamp``, ``middle``, ``low``). Depending on platform
    /// endianness, this may be different from performing a lexicographic
    /// numeric comparison on ``bitPattern`` directly.
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.timestamp, lhs.middle, lhs.low) <
        (rhs.timestamp, rhs.middle, rhs.low)
    }
}
extension BSON.Identifier:Hashable
{
    /// Hashes the bytes of this identifier in the order they are stored
    /// in memory.
    @inlinable public
    func hash(into hasher:inout Hasher)
    {
        withUnsafeBytes(of: self.bitPattern)
        {
            hasher.combine(bytes: $0)
        }
    }
}
