/// A BSON metatype. The raw value of this enumeration is the type code of the associated case
/// in BSON’s ABI.
extension BSON
{
    @frozen public
    enum AnyType:UInt8, Equatable, Hashable, Sendable
    {
        case double             = 0x01
        case string             = 0x02
        case document           = 0x03
        case list               = 0x04
        case binary             = 0x05

        case id                 = 0x07
        case bool               = 0x08
        case millisecond        = 0x09
        case null               = 0x0A
        case regex              = 0x0B
        case pointer            = 0x0C
        case javascript         = 0x0D

        case javascriptScope    = 0x0F
        case int32              = 0x10
        case uint64             = 0x11
        case int64              = 0x12
        case decimal128         = 0x13

        case min                = 0xFF
        case max                = 0x7F
    }
}
extension BSON.AnyType
{
    /// Calls ``init(rawValue:)``, but throws a ``TypeError`` instead of returning
    /// [`nil`]().
    @inlinable public
    init(code:UInt8) throws
    {
        if let variant:Self = .init(rawValue: code)
        {
            self = variant
        }
        else
        {
            throw BSON.TypeError.init(invalid: code)
        }
    }
    /// Converts the given type code to a variant type. This function will canonicalize
    /// deprecated type codes that have an isomorphic modern equivalent, but it will
    /// never change the ``pointer`` and ``javascriptScope`` types, because they do not
    /// have modern equivalents.
    @inlinable public
    init?(rawValue:UInt8)
    {
        switch rawValue
        {
        case 0x01:  self = .double
        case 0x02:  self = .string
        case 0x03:  self = .document
        case 0x04:  self = .list
        case 0x05:  self = .binary
        case 0x06:  self = .null
        case 0x07:  self = .id
        case 0x08:  self = .bool
        case 0x09:  self = .millisecond
        case 0x0A:  self = .null
        case 0x0B:  self = .regex
        case 0x0C:  self = .pointer
        case 0x0D:  self = .javascript
        case 0x0E:  self = .string
        case 0x0F:  self = .javascriptScope
        case 0x10:  self = .int32
        case 0x11:  self = .uint64
        case 0x12:  self = .int64
        case 0x13:  self = .decimal128
        case 0xFF:  self = .min
        case 0x7F:  self = .max
        default:    return nil
        }
    }
}
extension BSON.AnyType:Comparable
{
    @inlinable public
    static func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
