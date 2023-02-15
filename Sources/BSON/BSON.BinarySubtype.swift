extension BSON
{
    /// A BSON binary metatype. This type’s public API performs canonicalization
    /// and therefore instances of this type are safe to compare.
    @frozen public 
    struct BinarySubtype:Hashable, RawRepresentable, Sendable
    {
        @inlinable public static var generic:Self       { .init(unchecked: 0x00) }
        @inlinable public static var function:Self      { .init(unchecked: 0x01) }
        @inlinable public static var uuid:Self          { .init(unchecked: 0x04) }
        @inlinable public static var md5:Self           { .init(unchecked: 0x05) }
        @inlinable public static var encrypted:Self     { .init(unchecked: 0x06) }
        @inlinable public static var compressed:Self    { .init(unchecked: 0x07) }

        public
        let rawValue:UInt8

        /// Initializes a binary subtype from an unchecked subtype code.
        /// Performs no normalization.
        ///
        /// Most users should not need to call this initializer; prefer
        /// one of ``init(rawValue:)``, `custom(code:)`, or one of the
        /// known types: ``generic``, ``function``, ``uuid``, ``md5``,
        /// ``encrypted``, or ``compressed``.
        @inlinable public
        init(unchecked code:UInt8)
        {
            self.rawValue = code
        }
        /// Detects and normalizes a binary subtype from the given
        /// raw subtype code. Deprecated encodings (`0x02` and `0x03`)
        /// will be normalized to their canonical encoding.
        ///
        /// This initializer fails if `rawValue` is a reserved bit pattern.
        @inlinable public 
        init?(rawValue:UInt8)
        {
            switch rawValue
            {
            case 0x00, 0x02:    self.rawValue = 0x00
            case 0x01:          self.rawValue = 0x01
            case 0x03, 0x04:    self.rawValue = 0x04
            case 0x05:          self.rawValue = 0x05
            case 0x06:          self.rawValue = 0x06
            case 0x07:          self.rawValue = 0x07
            case 0x80 ... 0xFF: self.rawValue = rawValue
            default:            return nil
            }
        }
        /// Returns a custom binary subtype. Traps if `code` is less than `0x80`.
        @inlinable public static
        func custom(code:UInt8) -> Self
        {
            if code < 0x80
            {
                fatalError("custom code cannot be less than 0x80")
            }
            return .init(unchecked: code)
        }
    }
}
