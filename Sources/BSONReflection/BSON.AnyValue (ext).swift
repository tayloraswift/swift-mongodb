import BSON

extension BSON.AnyValue
{
    func description(indent:BSON.Indent) -> String
    {
        switch self
        {
        case .document(let document):
            return document.description(indent: indent)
        case .list(let list):
            return list.description(indent: indent)
        case .binary(let binary):
            return "{ binary data, type \(binary.subtype.rawValue) }"
        case .bool(let bool):
            return "\(bool)"
        case .decimal128(let decimal128):
            return "\(decimal128) as BSON.Decimal128"
        case .double(let double):
            return "\(double)"
        case .id(let id):
            return "\(id)"
        case .int32(let int32):
            return "\(int32)"
        case .int64(let int64):
            return "\(int64) as Int64"
        case .javascript(let javascript):
            return "'\(javascript)'"
        case .javascriptScope(_, _):
            return "{ javascript with scope }"
        case .max:
            return "max"
        case .millisecond(let millisecond):
            return "\(millisecond.value) as BSON.Millisecond"
        case .min:
            return "min"
        case .null:
            return "nil"
        case .pointer(let database, let id):
            return "\(database) + \(id)"
        case .regex(let regex):
            return "\(regex)"
        case .string(let utf8):
            return "\"\(utf8)\""
        case .uint64(let uint64):
            return "\(uint64) as UInt64"
        }
    }
}
extension BSON.AnyValue:CustomStringConvertible
{
    public
    var description:String { self.description(indent: "    ") }
}
extension BSON.AnyValue
{
    /// Performs a type-aware equivalence comparison.
    /// If both operands are a ``document(_:)`` (or ``list(_:)``), performs a recursive
    /// type-aware comparison by calling `BSON//DocumentView.~~(_:_:)`.
    /// If both operands are a ``string(_:)``, performs unicode-aware string comparison.
    /// If both operands are a ``double(_:)``, performs floating-point-aware
    /// numerical comparison.
    ///
    /// >   Warning:
    ///     Comparison of ``decimal128(_:)`` values uses bitwise equality. This library does
    ///     not support decimal equivalence.
    ///
    /// >   Warning:
    ///     Comparison of ``millisecond(_:)`` values uses integer equality. This library does
    ///     not support calendrical equivalence.
    ///
    /// >   Note:
    ///     The embedded document in the deprecated `javascriptScope(_:_:)` variant
    ///     also receives type-aware treatment.
    ///
    /// >   Note:
    ///     The embedded UTF-8 string in the deprecated `pointer(_:_:)` variant
    ///     also receives type-aware treatment.
    @inlinable public static
    func ~~ (lhs:Self, rhs:BSON.AnyValue<some RandomAccessCollection<UInt8>>) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.document     (let lhs), .document    (let rhs)):
            return lhs ~~ rhs
        case (.list         (let lhs), .list        (let rhs)):
            return lhs ~~ rhs
        case (.binary       (let lhs), .binary      (let rhs)):
            return lhs == rhs
        case (.bool         (let lhs), .bool        (let rhs)):
            return lhs == rhs
        case (.decimal128   (let lhs), .decimal128  (let rhs)):
            return lhs == rhs
        case (.double       (let lhs), .double      (let rhs)):
            return lhs == rhs
        case (.id           (let lhs), .id          (let rhs)):
            return lhs == rhs
        case (.int32        (let lhs), .int32       (let rhs)):
            return lhs == rhs
        case (.int64        (let lhs), .int64       (let rhs)):
            return lhs == rhs
        case (.javascript   (let lhs), .javascript  (let rhs)):
            return lhs == rhs
        case (.javascriptScope(let lhs, let lhsCode), .javascriptScope(let rhs, let rhsCode)):
            return lhsCode == rhsCode && lhs ~~ rhs
        case (.max,                     .max):
            return true
        case (.millisecond  (let lhs), .millisecond (let rhs)):
            return lhs.value == rhs.value
        case (.min,                     .min):
            return true
        case (.null,                    .null):
            return true
        case (.pointer(let lhs, let lhsID), .pointer(let rhs, let rhsID)):
            return lhsID == rhsID && lhs == rhs
        case (.regex        (let lhs), .regex       (let rhs)):
            return lhs == rhs
        case (.string       (let lhs), .string      (let rhs)):
            return lhs == rhs
        case (.uint64       (let lhs), .uint64      (let rhs)):
            return lhs == rhs

        default:
            return false
        }
    }
}
extension BSON.AnyValue
    where   Bytes:RangeReplaceableCollection<UInt8>,
            Bytes:RandomAccessCollection<UInt8>,
            Bytes.Index == Int
{
    /// Recursively parses and re-encodes any embedded documents (and list-documents)
    /// in this variant value.
    @inlinable public
    func canonicalized() throws -> Self
    {
        switch self
        {
        case    .document(let document):
            return .document(try document.canonicalized())
        case    .list(let list):
            return .list(try list.canonicalized())
        case    .binary,
                .bool,
                .decimal128,
                .double,
                .id,
                .int32,
                .int64,
                .javascript:
            return self
        case    .javascriptScope(let scope, let utf8):
            return .javascriptScope(try scope.canonicalized(), utf8)
        case    .max,
                .millisecond,
                .min,
                .null,
                .pointer,
                .regex,
                .string,
                .uint64:
            return self
        }
    }
}
