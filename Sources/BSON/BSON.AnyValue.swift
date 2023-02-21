extension BSON
{
    /// Any BSON value.
    @frozen public
    enum AnyValue<Bytes> where Bytes:RandomAccessCollection<UInt8>
    {
        /// A general embedded document.
        case document(BSON.DocumentView<Bytes>)
        /// An embedded list-document.
        case list(BSON.ListView<Bytes>)
        /// A binary array.
        case binary(BSON.BinaryView<Bytes>)
        /// A boolean.
        case bool(Bool)
        /// An [IEEE 754-2008 128-bit decimal](https://en.wikipedia.org/wiki/Decimal128_floating-point_format).
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
        case javascript(BSON.UTF8View<Bytes>)
        /// A javascript scope containing code. This variant is maintained for 
        /// backward-compatibility with older versions of BSON and 
        /// should not be generated. (Prefer ``javascript(_:)``.)
        case javascriptScope(BSON.DocumentView<Bytes>, BSON.UTF8View<Bytes>)
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
        case pointer(BSON.UTF8View<Bytes>, BSON.Identifier)
        /// A regex.
        case regex(BSON.Regex)
        /// A UTF-8 string, possibly containing invalid code units.
        /// The payload is a library type to permit efficient document traversal.
        case string(BSON.UTF8View<Bytes>)
        /// A 64-bit unsigned integer.
        ///
        /// MongoDB also uses this type internally to represent timestamps.
        case uint64(UInt64)
    }
}
extension BSON.AnyValue:Equatable
{
}
extension BSON.AnyValue:Sendable where Bytes:Sendable
{
}
extension BSON.AnyValue
{
    /// The type of this variant value.
    @inlinable public
    var type:BSON
    {
        switch self
        {
        case .document:         return .document
        case .list:             return .list
        case .binary:           return .binary
        case .bool:             return .bool
        case .decimal128:       return .decimal128
        case .double:           return .double
        case .id:               return .id
        case .int32:            return .int32
        case .int64:            return .int64
        case .javascript:       return .javascript
        case .javascriptScope:  return .javascriptScope
        case .max:              return .max
        case .millisecond:      return .millisecond
        case .min:              return .min
        case .null:             return .null
        case .pointer:          return .pointer
        case .regex:            return .regex
        case .string:           return .string
        case .uint64:           return .uint64
        }
    }
    /// The size of this variant value when encoded.
    @inlinable public
    var size:Int
    {
        switch self
        {
        case .document(let document):
            return document.size
        case .list(let list):
            return list.size
        case .binary(let binary):
            return binary.size
        case .bool:
            return 1
        case .decimal128:
            return 16
        case .double:
            return 8
        case .id:
            return 12
        case .int32:
            return 4
        case .int64:
            return 8
        case .javascript(let utf8):
            return utf8.size
        case .javascriptScope(let scope, let utf8):
            return 4 + utf8.size + scope.size
        case .max:
            return 0
        case .millisecond:
            return 8
        case .min:
            return 0
        case .null:
            return 0
        case .pointer(let database, _):
            return 12 + database.size
        case .regex(let regex):
            return regex.size
        case .string(let string):
            return string.size
        case .uint64:
            return 8
        }
    }
}

extension BSON.AnyValue:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .document(let document):
            return ".document(\(document))"
        case .list(let list):
            return ".list(\(list))"
        case .binary(let binary):
            return ".binary(\(binary))"
        case .bool(let bool):
            return ".bool(\(bool))"
        case .decimal128(let decimal128):
            return ".decimal128(\(decimal128))"
        case .double(let double):
            return ".double(\(double))"
        case .id(let id):
            return ".id(\(id))"
        case .int32(let int32):
            return ".int32(\(int32))"
        case .int64(let int64):
            return ".int64(\(int64))"
        case .javascript(let javascript):
            return ".javascript(\"\(javascript)\")"
        case .javascriptScope(let scope, let javascript):
            return ".javascriptScope(\(scope), \"\(javascript)\")"
        case .max:
            return ".max"
        case .millisecond(let millisecond):
            return ".millisecond(\(millisecond))"
        case .min:
            return ".min"
        case .null:
            return ".null"
        case .pointer(let database, let id):
            return ".pointer(\(database), \(id))"
        case .regex(let regex):
            return ".regex(\(regex))"
        case .string(let string):
            return ".string(\"\(string)\")"
        case .uint64(let uint64):
            return ".uint64(\(uint64))"
        }
    }
}

