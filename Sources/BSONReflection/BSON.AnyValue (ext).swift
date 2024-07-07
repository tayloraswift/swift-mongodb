import BSON
import UnixTime

extension BSON.AnyValue
{
    func description(indent:BSON.Indent) -> String
    {
        switch self
        {
        case .document(let document):
            document.description(indent: indent)
        case .list(let list):
            list.description(indent: indent)
        case .binary(let binary):
            "{ binary data, type \(binary.subtype.rawValue) }"
        case .bool(let bool):
            "\(bool)"
        case .decimal128(let decimal128):
            "\(decimal128) as BSON.Decimal128"
        case .double(let double):
            "\(double)"
        case .id(let id):
            "\(id)"
        case .int32(let int32):
            "\(int32)"
        case .int64(let int64):
            "\(int64) as Int64"
        case .javascript(let javascript):
            "'\(javascript)'"
        case .javascriptScope(_, _):
            "{ javascript with scope }"
        case .max:
            "max"
        case .millisecond(let millisecond):
            "\(millisecond.index) as UnixMillisecond"
        case .min:
            "min"
        case .null:
            "null"
        case .pointer(let database, let id):
            "\(database) + \(id)"
        case .regex(let regex):
            "\(regex)"
        case .string(let utf8):
            "\"\(utf8)\""
        case .timestamp(let timestamp):
            "\(timestamp)"
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
    func ~~ (lhs:Self, rhs:BSON.AnyValue) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.document     (let lhs), .document    (let rhs)):
            lhs ~~ rhs
        case (.list         (let lhs), .list        (let rhs)):
            lhs ~~ rhs
        case (.binary       (let lhs), .binary      (let rhs)):
            lhs == rhs
        case (.bool         (let lhs), .bool        (let rhs)):
            lhs == rhs
        case (.decimal128   (let lhs), .decimal128  (let rhs)):
            lhs == rhs
        case (.double       (let lhs), .double      (let rhs)):
            lhs == rhs
        case (.id           (let lhs), .id          (let rhs)):
            lhs == rhs
        case (.int32        (let lhs), .int32       (let rhs)):
            lhs == rhs
        case (.int64        (let lhs), .int64       (let rhs)):
            lhs == rhs
        case (.javascript   (let lhs), .javascript  (let rhs)):
            lhs == rhs
        case (.javascriptScope(let lhs, let lhsCode), .javascriptScope(let rhs, let rhsCode)):
            lhsCode == rhsCode && lhs ~~ rhs
        case (.max,                     .max):
            true
        case (.millisecond  (let lhs), .millisecond (let rhs)):
            lhs.index == rhs.index
        case (.min,                     .min):
            true
        case (.null,                    .null):
            true
        case (.pointer(let lhs, let lhsID), .pointer(let rhs, let rhsID)):
            lhsID == rhsID && lhs == rhs
        case (.regex        (let lhs), .regex       (let rhs)):
            lhs == rhs
        case (.string       (let lhs), .string      (let rhs)):
            lhs == rhs
        case (.timestamp    (let lhs), .timestamp   (let rhs)):
            lhs == rhs

        default:
            false
        }
    }
}
extension BSON.AnyValue
{
    /// Recursively parses and re-encodes any embedded documents (and list-documents)
    /// in this variant value.
    @inlinable public
    func canonicalized() throws -> Self
    {
        switch self
        {
        case    .document(let document):
            .document(try document.canonicalized())
        case    .list(let list):
            .list(try list.canonicalized())
        case    .binary,
                .bool,
                .decimal128,
                .double,
                .id,
                .int32,
                .int64,
                .javascript:
            self
        case    .javascriptScope(let scope, let utf8):
            .javascriptScope(try scope.canonicalized(), utf8)
        case    .max,
                .millisecond,
                .min,
                .null,
                .pointer,
                .regex,
                .string,
                .timestamp:
            self
        }
    }
}
