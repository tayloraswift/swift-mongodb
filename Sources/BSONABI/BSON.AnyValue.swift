extension BSON
{
    /// Any BSON value.
    @frozen public
    enum AnyValue:Sendable
    {
        /// A general embedded document.
        case document(BSON.Document)
        /// An embedded list-document.
        case list(BSON.List)
        /// A binary array.
        case binary(BSON.BinaryView<ArraySlice<UInt8>>)
        /// A boolean.
        case bool(Bool)
        /// An [IEEE 754-2008 128-bit
        /// decimal](https://en.wikipedia.org/wiki/Decimal128_floating-point_format).
        case decimal128(BSON.Decimal128)
        /// A double-precision float.
        case double(Double)
        /// A MongoDB object reference.
        case id(BSON.Identifier)
        /// A 32-bit signed integer.
        case int32(Int32)
        /// A 64-bit signed integer.
        case int64(Int64)
        /// Javascript code.
        /// The payload is a library type to permit efficient document traversal.
        case javascript(BSON.UTF8View<ArraySlice<UInt8>>)
        /// A javascript scope containing code. This variant is maintained for
        /// backward-compatibility with older versions of BSON and
        /// should not be generated. (Prefer ``javascript(_:)``.)
        case javascriptScope(BSON.Document, BSON.UTF8View<ArraySlice<UInt8>>)
        /// The MongoDB max-key.
        case max
        /// UTC milliseconds since the Unix epoch.
        case millisecond(BSON.Millisecond)
        /// The MongoDB min-key.
        case min
        /// An explicit null.
        case null
        /// A MongoDB database pointer. This variant is maintained for
        /// backward-compatibility with older versions of BSON and
        /// should not be generated. (Prefer ``id(_:)``.)
        case pointer(BSON.UTF8View<ArraySlice<UInt8>>, BSON.Identifier)
        /// A regex.
        case regex(BSON.Regex)
        /// A UTF-8 string, possibly containing invalid code units.
        /// The payload is a library type to permit efficient document traversal.
        case string(BSON.UTF8View<ArraySlice<UInt8>>)
        /// A 64-bit unsigned integer.
        ///
        /// MongoDB also uses this type internally to represent timestamps.
        ///
        /// >   Important:
        ///     MongoDB replaces zero values of this type in top-level document
        ///     fields with the bit pattern of its “current timestamp”. This
        ///     behavior is not part of the BSON specification, and does not
        ///     affect roundtrippability of BSON documents that are not stored
        ///     in a Mongo database.
        case timestamp(BSON.Timestamp)
    }
}
extension BSON.AnyValue
{
    @available(*, deprecated, renamed: "timestamp(_:)")
    @inlinable public static
    func uint64(_ value:UInt64) -> Self
    {
        .timestamp(.init(value))
    }
}
extension BSON.AnyValue:Equatable
{
}
extension BSON.AnyValue
{
    /// The type of this variant value.
    @inlinable public
    var type:BSON.AnyType
    {
        switch self
        {
        case .document:         .document
        case .list:             .list
        case .binary:           .binary
        case .bool:             .bool
        case .decimal128:       .decimal128
        case .double:           .double
        case .id:               .id
        case .int32:            .int32
        case .int64:            .int64
        case .javascript:       .javascript
        case .javascriptScope:  .javascriptScope
        case .max:              .max
        case .millisecond:      .millisecond
        case .min:              .min
        case .null:             .null
        case .pointer:          .pointer
        case .regex:            .regex
        case .string:           .string
        case .timestamp:        .timestamp
        }
    }
    /// The size of this variant value when encoded.
    @inlinable public
    var size:Int
    {
        switch self
        {
        case .document(let document):
            document.size
        case .list(let list):
            list.size
        case .binary(let binary):
            binary.size
        case .bool:
            1
        case .decimal128:
            16
        case .double:
            8
        case .id:
            12
        case .int32:
            4
        case .int64:
            8
        case .javascript(let utf8):
            utf8.size
        case .javascriptScope(let scope, let utf8):
            4 + utf8.size + scope.size
        case .max:
            0
        case .millisecond:
            8
        case .min:
            0
        case .null:
            0
        case .pointer(let database, _):
            12 + database.size
        case .regex(let regex):
            regex.size
        case .string(let string):
            string.size
        case .timestamp:
            8
        }
    }
}
extension BSON.AnyValue
{
    /// Promotes a nil result to a thrown ``TypecastError``.
    ///
    /// If `T` conforms to ``BSONDecodable``, prefer calling its throwing
    /// ``BSONDecodable/init(bson:) [7O4O3]`` to calling this method directly.
    ///
    /// >   Throws: A ``TypecastError`` if the given curried method returns nil.
    @inline(__always)
    @inlinable public
    func cast<T>(with cast:(Self) throws -> T?) throws -> T
    {
        if let value:T = try cast(self)
        {
            return value
        }
        else
        {
            throw BSON.TypecastError<T>.init(invalid: self.type)
        }
    }
}
extension BSON.AnyValue
{
    /// Attempts to load an instance of ``Bool`` from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant if it matches ``bool(_:)``,
    ///     nil otherwise.
    @inlinable public
    func `as`(_:Bool.Type) -> Bool?
    {
        switch self
        {
        case .bool(let bool):   bool
        default:                nil
        }
    }
    /// Attempts to load an instance of some ``FixedWidthInteger`` from this variant.
    ///
    /// -   Returns:
    ///     An integer derived from the payload of this variant
    ///     if it matches one of ``int32(_:)``, ``int64(_:)``, or
    ///     ``timestamp(_:)``, and it can be represented exactly by `T`;
    ///     nil otherwise.
    ///
    /// The ``decimal128(_:)``, ``double(_:)``, and ``millisecond(_:)``
    /// variants will *not* match.
    ///
    /// This method reports failure in two ways — it returns nil on a type
    /// mismatch, and it throws an ``IntegerOverflowError`` if this variant
    /// was an integer, but it could not be represented exactly by `T`.
    @inlinable public
    func `as`<Integer>(_:Integer.Type) throws -> Integer?
        where Integer:FixedWidthInteger
    {
        switch self
        {
        case .int32(let int32):
            if let integer:Integer = .init(exactly: int32)
            {
                return integer
            }
            else
            {
                throw BSON.IntegerOverflowError<Integer>.int32(int32)
            }
        case .int64(let int64):
            if let integer:Integer = .init(exactly: int64)
            {
                return integer
            }
            else
            {
                throw BSON.IntegerOverflowError<Integer>.int64(int64)
            }
        case .timestamp(let timestamp):
            if let integer:Integer = .init(exactly: timestamp.value)
            {
                return integer
            }
            else
            {
                throw BSON.IntegerOverflowError<Integer>.uint64(timestamp.value)
            }
        default:
            return nil
        }
    }
    /// Attempts to load an instance of some ``BinaryFloatingPoint`` type from
    /// this variant.
    ///
    /// -   Returns:
    ///     The closest value of `T` to the payload of this
    ///     variant if it matches ``double(_:)``, nil otherwise.
    @inlinable public
    func `as`<Fraction>(_:Fraction.Type) -> Fraction?
        where Fraction:BinaryFloatingPoint
    {
        switch self
        {
        case .double(let double):   return .init(double)
        default:                    return nil
        }
    }
    /// Attempts to load an instance of ``Decimal128`` from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant if it matches ``decimal128(_:)``,
    ///     nil otherwise.
    @inlinable public
    func `as`(_:BSON.Decimal128.Type) -> BSON.Decimal128?
    {
        switch self
        {
        case .decimal128(let decimal):  decimal
        default:                        nil
        }
    }
    /// Attempts to load an instance of ``Identifier`` from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant if it matches ``id(_:)`` or
    ///     ``pointer(_:_:)``, nil otherwise.
    @inlinable public
    func `as`(_:BSON.Identifier.Type) -> BSON.Identifier?
    {
        switch self
        {
        case .id(let id):
            id
        case .pointer(_, let id):
            id
        default:
            nil
        }
    }
    /// Attempts to load an instance of ``Millisecond`` from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant if it matches ``millisecond(_:)``,
    ///     nil otherwise.
    @inlinable public
    func `as`(_:BSON.Millisecond.Type) -> BSON.Millisecond?
    {
        switch self
        {
        case .millisecond(let millisecond):
            millisecond
        default:
            nil
        }
    }
    /// Attempts to load an instance of ``Regex`` from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant if it matches ``regex(_:)``,
    ///     nil otherwise.
    @inlinable public
    func `as`(_:BSON.Regex.Type) -> BSON.Regex?
    {
        switch self
        {
        case .regex(let regex):
            regex
        default:
            nil
        }
    }
    /// Attempts to load an instance of ``String`` from this variant.
    /// Its UTF-8 code units will be validated (and repaired if needed).
    ///
    /// -   Returns:
    ///     The payload of this variant, decoded to a ``String``, if it matches
    ///     either ``string(_:)`` or ``javascript(_:)``, nil
    ///     otherwise.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the length of the string.
    @inlinable public
    func `as`(_:String.Type) -> String?
    {
        self.utf8?.description
    }
}
extension BSON.AnyValue
{
    /// Attempts to load an explicit ``null`` from this variant.
    ///
    /// -   Returns:
    ///     nil in the inner optional if this variant is ``null``,
    //      nil in the outer optional otherwise.
    @available(*, deprecated, message: "Use the BSON.Null overload instead.")
    @inlinable public
    func `as`(_:Never?.Type) -> Never??
    {
        switch self
        {
        case .null: (nil as Never?) as Never??
        default:    nil            as Never??
        }
    }
    /// Attempts to load an explicit ``null`` from this variant.
    ///
    /// -   Returns:
    ///     A (the) instance of ``Null`` if this variant is ``null``, nil otherwise.
    @inlinable public
    func `as`(_:BSON.Null.Type) -> BSON.Null?
    {
        switch self
        {
        case .null: .init()
        default:    nil
        }
    }
    /// Attempts to load a ``max`` key from this variant.
    ///
    /// -   Returns:
    ///     A (the) instance of ``Max`` if this variant is ``max``, nil otherwise.
    @inlinable public
    func `as`(_:BSON.Max.Type) -> BSON.Max?
    {
        switch self
        {
        case .max:  .init()
        default:    nil
        }
    }
    /// Attempts to load a ``min`` key from this variant.
    ///
    /// -   Returns:
    ///     A (the) instance of ``min`` if this variant is ``min``, nil otherwise.
    @inlinable public
    func `as`(_:BSON.Min.Type) -> BSON.Min?
    {
        switch self
        {
        case .min:  .init()
        default:    nil
        }
    }
}
extension BSON.AnyValue
{
    /// Attempts to unwrap a binary array from this variant.
    ///
    /// -   Returns: The payload of this variant if it matches ``binary(_:)``,
    ///     nil otherwise.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    var binary:BSON.BinaryView<ArraySlice<UInt8>>?
    {
        switch self
        {
        case .binary(let binary):
            binary
        default:
            nil
        }
    }
    /// Attempts to unwrap a document from this variant.
    ///
    /// -   Returns: The payload of this variant if it matches ``document(_:)``
    ///     **or** ``list(_:)``, nil otherwise.
    ///
    /// If the variant was a list, the string keys of the returned document are likely
    /// (but not guaranteed) to be the list indices encoded as base-10 strings, without
    /// leading zeros.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    var document:BSON.Document?
    {
        switch self
        {
        case .document(let document):   document
        case .list(let list):           .init(list: list)
        default:                        nil
        }
    }
    /// Attempts to unwrap a list from this variant.
    ///
    /// -   Returns:
    ///     The payload of this variant if it matches ``list(_:)``,
    ///     nil otherwise.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    var list:BSON.List?
    {
        switch self
        {
        case .list(let list):   list
        default:                nil
        }
    }
    /// Attempts to unwrap an instance of ``UTF8View`` from this variant. Its UTF-8
    /// code units will *not* be validated, which allowes this method to return
    /// in constant time.
    ///
    /// -   Returns:
    ///     The payload of this variant if it matches either ``string(_:)``
    ///     or ``javascript(_:)``, nil otherwise.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    var utf8:BSON.UTF8View<ArraySlice<UInt8>>?
    {
        switch self
        {
        case .javascript(let code): code
        case .string(let code):     code
        default:                    nil
        }
    }
}

extension BSON.AnyValue:ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByExtendedGraphemeClusterLiteral,
    ExpressibleByUnicodeScalarLiteral,
    ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self = .string(.init(from: stringLiteral))
    }
    @inlinable public
    init(arrayLiteral:Self...)
    {
        self = .list(.init(elements: arrayLiteral))
    }
    @inlinable public
    init(dictionaryLiteral:(BSON.Key, Self)...)
    {
        self = .document(.init(fields: dictionaryLiteral))
    }
}

extension BSON.AnyValue:ExpressibleByFloatLiteral
{
    @inlinable public
    init(floatLiteral:Double)
    {
        self = .double(floatLiteral)
    }
}
extension BSON.AnyValue:ExpressibleByIntegerLiteral
{
    /// Creates an instance initialized to the specified integer value.
    /// It will be an ``int32(_:)`` value if it fits, otherwise it will
    /// be an ``int64(_:)``.
    ///
    /// Although MongoDB uses ``Int32`` as its default integer type,
    /// this library infers integer literals to be of type ``Int`` for
    /// consistency with the rest of the Swift language.
    @inlinable public
    init(integerLiteral:Int)
    {
        if  let int32:Int32 = .init(exactly: integerLiteral)
        {
            self = .int32(int32)
        }
        else
        {
            self = .int64(Int64.init(integerLiteral))
        }
    }
}
extension BSON.AnyValue:ExpressibleByBooleanLiteral
{
    @inlinable public
    init(booleanLiteral:Bool)
    {
        self = .bool(booleanLiteral)
    }
}
