import BSONSchema
import BSONUnions

extension Mongo
{
    /// @import(BSONUnions)
    /// An **aggregation expression** is the most general type that an aggregation
    /// pipeline stage can take as a value.
    ///
    /// Aggregation expressions are closely related to ``AnyBSON``, in a sense they
    /// can be thought of as ``AnyBSON`` with backing storage constrained to
    /// [`[UInt8]`]() (for container values), and API that is optimized for encoding
    /// rather than decoding.
    public
    enum Expression:Sendable
    {
        /// A general embedded document.
        case document(BSON.Fields)
        /// An embedded tuple-document.
        case tuple([Self])
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
        /// The MongoDB max-key.
        case max
        /// UTC milliseconds since the Unix epoch.
        case millisecond(BSON.Millisecond)
        /// The MongoDB min-key.
        case min
        /// An explicit null.
        case null
        /// A regex.
        case regex(BSON.Regex)
        /// A native swift string, which may encode a field path or a system
        /// variable.
        ///
        /// Do not use this case-constructor to encode arbitrary strings,
        /// because it will not escape strings with leading dollar signs (`$`).
        //
        /// To specify an absolute field path, use the `$$ROOT` system variable.
        ///
        /// ```swift
        /// let absolute:Expression = "$$ROOT.example"
        /// ```
        ///
        /// The `$$CURRENT` system variable can also be used this way, but there
        /// is rarely reason to, because field path expressions are relative to
        /// `$$CURRENT` by default.
        case string(String)
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func document(_ populate:(inout BSON.Fields) throws -> ()) rethrows -> Self
    {
        .document(try .init(with: populate))
    }

    /// Escapes the string argument “intelligently”, returning a `$literal`
    /// operator expression if the string begins with a dollar sign (`$`).
    ///
    /// To escape the string unconditionally, call ``literal(escaping:)``
    /// directly.
    @inlinable public static
    func literal(_ string:some StringProtocol & BSONEncodable) -> Self
    {
        if case "$"? = string.first
        {
            return .literal(escaping: string)
        }
        else
        {
            return .string(.init(string))
        }
    }

    /// Creates a `$literal` operator expression. This method always
    /// encodes a nested document.
    @inlinable public static
    func literal(escaping value:some BSONEncodable) -> Self
    {
        .document
        {
            $0["$literal"] = value
        }
    }
}
extension Mongo.Expression
{
    /// The string [`"$$CLUSTER_TIME"`]().
    @inlinable public static
    var CLUSTER_TIME:Self
    {
        .string("$$CLUSTER_TIME")
    }
    /// The string [`"$$DESCEND"`]().
    @inlinable public static
    var DESCEND:Self
    {
        .string("$$DESCEND")
    }
    /// The string [`"$$KEEP"`]().
    @inlinable public static
    var KEEP:Self
    {
        .string("$$KEEP")
    }
    /// The string [`"$$PRUNE"`]().
    @inlinable public static
    var PRUNE:Self
    {
        .string("$$PRUNE")
    }
    /// The string [`"$$NOW"`]().
    @inlinable public static
    var NOW:Self
    {
        .string("$$NOW")
    }
    /// The string [`"$$REMOVE"`]().
    @inlinable public static
    var REMOVE:Self
    {
        .string("$$REMOVE")
    }
}
extension Mongo.Expression:ExpressibleByBooleanLiteral
{
    @inlinable public
    init(booleanLiteral:Bool)
    {
        self = .bool(booleanLiteral)
    }
}
extension Mongo.Expression:ExpressibleByFloatLiteral
{
    @inlinable public
    init(floatLiteral:Double)
    {
        self = .double(floatLiteral)
    }
}
extension Mongo.Expression:ExpressibleByIntegerLiteral
{
    @inlinable public
    init(integerLiteral:Int64)
    {
        self = .int64(integerLiteral)
    }
}
extension Mongo.Expression:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self = .string(stringLiteral)
    }
}
extension Mongo.Expression:BSONDecodable
{
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast
        {
            switch $0
            {
            case .document(let document):
                return .document(.init(bson: document))

            case .tuple(let tuple):
                return .tuple(try .init(bson: tuple))
            
            case .bool(let bool):
                return .bool(bool)
            
            case .decimal128(let decimal):
                return .decimal128(decimal)
            
            case .double(let double):
                return .double(double)
            
            case .id(let id):
                return .id(id)
            
            case .int32(let int32):
                return .int32(int32)

            case .int64(let int64):
                return .int64(int64)
                        
            case .max:
                return .max
            
            case .min:
                return .min
            
            case .millisecond(let millisecond):
                return .millisecond(millisecond)
            
            case .null:
                return .null
            
            case .regex(let regex):
                return .regex(regex)

            case .string(let utf8):
                return .string(.init(bson: utf8))
            
            case .binary, .javascript, .javascriptScope, .pointer, .uint64:
                // not allowed
                return nil
            }
        }
    }
}
extension Mongo.Expression:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .document(let document):
            document.encode(to: &field)
        
        case .tuple(let tuple):
            tuple.encode(to: &field)
        
        case .bool(let bool):
            bool.encode(to: &field)
        
        case .decimal128(let decimal):
            decimal.encode(to: &field)
        
        case .double(let double):
            double.encode(to: &field)
        
        case .id(let id):
            id.encode(to: &field)
        
        case .int32(let int32):
            int32.encode(to: &field)
        
        case .int64(let int64):
            int64.encode(to: &field)
        
        case .max:
            field.encode(max: .init())
        
        case .millisecond(let millisecond):
            millisecond.encode(to: &field)
        
        case .min:
            field.encode(min: .init())
        
        case .null:
            field.encode(null: ())
        
        case .regex(let regex):
            regex.encode(to: &field)
        
        case .string(let string):
            string.encode(to: &field)
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func abs(_ expression:Self) -> Self
    {
        .document
        {
            $0["$abs"] = expression
        }
    }

    @inlinable public static
    func add(_ expressions:Self...) -> Self
    {
        .add(expressions)
    }
    @inlinable public static
    func add(_ expressions:[Self]) -> Self
    {
        .document
        {
            $0["$add"] = expressions
        }
    }

    @inlinable public static
    func ceil(_ expression:Self) -> Self
    {
        .document
        {
            $0["$ceil"] = expression
        }
    }

    @inlinable public static
    func divide(_ dividend:Self, by divisor:Self) -> Self
    {
        .document
        {
            $0["$divide"] = [dividend, divisor]
        }
    }

    @inlinable public static
    func exp(_ expression:Self) -> Self
    {
        .document
        {
            $0["$exp"] = expression
        }
    }

    @inlinable public static
    func floor(_ expression:Self) -> Self
    {
        .document
        {
            $0["$floor"] = expression
        }
    }

    @inlinable public static
    func ln(_ expression:Self) -> Self
    {
        .document
        {
            $0["$ln"] = expression
        }
    }

    @inlinable public static
    func log(base:Self, _ expression:Self) -> Self
    {
        .document
        {
            // note: order of arguments is reversed!
            $0["$log"] = [expression, base]
        }
    }

    @inlinable public static
    func log10(_ expression:Self) -> Self
    {
        .document
        {
            $0["$log10"] = expression
        }
    }

    @inlinable public static
    func mod(_ dividend:Self, by divisor:Self) -> Self
    {
        .document
        {
            $0["$mod"] = [dividend, divisor]
        }
    }

    @inlinable public static
    func multiply(_ expressions:Self...) -> Self
    {
        .multiply(expressions)
    }
    @inlinable public static
    func multiply(_ expressions:[Self]) -> Self
    {
        .document
        {
            $0["$multiply"] = expressions
        }
    }

    @inlinable public static
    func pow(base:Self, _ expression:Self) -> Self
    {
        .document
        {
            $0["$pow"] = [base, expression]
        }
    }

    @inlinable public static
    func round(_ expression:Self, places:Self = 0) -> Self
    {
        .document
        {
            $0["$round"] = [expression, places]
        }
    }

    @inlinable public static
    func sqrt(_ expression:Self) -> Self
    {
        .document
        {
            $0["$sqrt"] = expression
        }
    }

    @inlinable public static
    func subtract(_ minuend:Self, minus subtrahend:Self) -> Self
    {
        .document
        {
            $0["$subtract"] = [minuend, subtrahend]
        }
    }

    @inlinable public static
    func trunc(_ expression:Self, places:Self = 0) -> Self
    {
        .document
        {
            $0["$trunc"] = [expression, places]
        }
    }
}

extension Mongo.Expression
{
    @available(*, unavailable, renamed: "element(of:at:)")
    public static
    func arrayElemAt(_ array:Self, _ index:Self) -> Self
    {
        .element(of: array, at: index)
    }
    @available(*, unavailable, renamed: "toObject(array:)")
    public static
    func arrayToObject(_ array:Self) -> Self
    {
        .toObject(array: array)
    }
    @available(*, unavailable, renamed: "toArray(object:)")
    public static
    func objectToArray(_ object:Self) -> Self
    {
        .toArray(object: object)
    }
    @available(*, unavailable, renamed: "concatenate(arrays:)")
    public static
    func concatArrays(_ arrays:[Self]) -> Self
    {
        .concatenate(arrays: arrays)
    }
    @available(*, unavailable, renamed: "filter(_:where:limit:as:)")
    public static
    func filter(input array:Self, cond predicate:Self, as binding:String?, limit:Self) -> Self
    {
        .filter(array, where: predicate, limit: limit, as: binding)
    }
    @available(*, unavailable, renamed: "first(_:of:)")
    public static
    func firstN(_ count:Self, array:Self) -> Self
    {
        .first(count, of: array)
    }
    @available(*, unavailable, renamed: "index(of:in:range:)")
    public static
    func indexOfArray(_ array:Self, expression:Self, start:Self?, end:Self?) -> Self
    {
        .index(of: expression, in: array, range: start.map { ($0, end) })
    }
    @available(*, unavailable, renamed: "max(_:of:)")
    public static
    func maxN(_ count:Self, array:Self) -> Self
    {
        .max(count, of: array)
    }
    @available(*, unavailable, renamed: "reverse(array:)")
    public static
    func reverseArray(_ array:Self) -> Self
    {
        .reverse(array: array)
    }
    @available(*, unavailable, renamed: "sort(array:by:)")
    public static
    func sortArray(_ array:Self, by ordering:Self) -> Self
    {
        .sort(array, by: ordering)
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func element(of array:Self, at index:Self) -> Self
    {
        .document
        {
            $0["$arrayElemAt"] = [array, index]
        }
    }
    
    @inlinable public static
    func toArray(object:Self) -> Self
    {
        .document
        {
            $0["$objectToArray"] = object
        }
    }
    
    @inlinable public static
    func toObject(array:Self) -> Self
    {
        .document
        {
            $0["$arrayToObject"] = array
        }
    }

    @inlinable public static
    func concatenate(arrays:Self...) -> Self
    {
        .concatenate(arrays: arrays)
    }
    @inlinable public static
    func concatenate(arrays:[Self]) -> Self
    {
        .document
        {
            $0["$concatArrays"] = arrays
        }
    }

    @inlinable public static
    func first(of array:Self) -> Self
    {
        .document
        {
            $0["$first"] = array
        }
    }

    @inlinable public static
    func first(_ count:Self, of array:Self) -> Self
    {
        .document
        {
            $0["$firstN"] = .init
            {
                $0["n"] = count
                $0["input"] = array
            }
        }
    }
    
    @inlinable public static
    func `in`(_ expression:Self, in array:Self) -> Self
    {
        .document
        {
            $0["$in"] = [expression, array]
        }
    }

    @inlinable public static
    func index(of expression:Self, in array:Self, range:(start:Self, end:Self?)? = nil) -> Self
    {
        .document
        {
            switch range
            {
            case nil:
                $0["$indexOfArray"] = [array, expression]
            case (let start, nil)?:
                $0["$indexOfArray"] = [array, expression, start]
            case (let start, let end?)?:
                $0["$indexOfArray"] = [array, expression, start, end]
            }
        }
    }

    /// Creates an `$isArray` expression. This method already brackets the expression
    /// when passing it in an argument tuple; doing so manually will create an
    /// expression that always evaluates to true.
    @inlinable public static
    func isArray(_ expression:Self) -> Self
    {
        .document
        {
            $0["$isArray"] = [expression]
        }
    }

    @inlinable public static
    func last(of array:Self) -> Self
    {
        .document
        {
            $0["$last"] = array
        }
    }

    @inlinable public static
    func last(_ count:Self, of array:Self) -> Self
    {
        .document
        {
            $0["$lastN"] = .init
            {
                $0["n"] = count
                $0["input"] = array
            }
        }
    }

    @inlinable public static
    func max(_ count:Self, of array:Self) -> Self
    {
        .document
        {
            $0["$maxN"] = .init
            {
                $0["n"] = count
                $0["input"] = array
            }
        }
    }

    @inlinable public static
    func min(_ count:Self, of array:Self) -> Self
    {
        .document
        {
            $0["$minN"] = .init
            {
                $0["n"] = count
                $0["input"] = array
            }
        }
    }

    public static
    func range(from start:Self, to end:Self, by step:Self? = nil) -> Self
    {
        .document
        {
            if let step:Self
            {
                $0["$range"] = [start, end, step]
            }
            else
            {
                $0["$range"] = [start, end]
            }
        }
    }

    @inlinable public static
    func reverse(array:Self) -> Self
    {
        .document
        {
            $0["$reverseArray"] = array
        }
    }

    @inlinable public static
    func size(of array:Self) -> Self
    {
        .document
        {
            $0["$size"] = array
        }
    }
    
    @inlinable public static
    func slice(_ array:Self, distance:Self) -> Self
    {
        .document
        {
            $0["$slice"] = [array, distance]
        }
    }
    @inlinable public static
    func slice(_ array:Self, at index:Self, count:Self) -> Self
    {
        .document
        {
            $0["$slice"] = [array, index, count]
        }
    }

    @inlinable public static
    func sort(_ array:Self, by populate:(inout BSON.Fields) throws -> ()) rethrows -> Self
    {
        .sort(array, by: try .document(populate))
    }
    @inlinable public static
    func sort(_ array:Self, by ordering:Self) -> Self
    {
        .document
        {
            $0["$sortArray"] = .init
            {
                $0["input"] = array
                $0["sortBy"] = ordering
            }
        }
    }

    @inlinable public static
    func zip(arrays:Self...) -> Self
    {
        .zip(arrays: arrays)
    }
    @inlinable public static
    func zip(arrays:[Self]) -> Self
    {
        .document
        {
            $0["$zip"] = .init
            {
                $0["inputs"] = arrays
            }
        }
    }

    @inlinable public static
    func zip(padding arrays:Self..., with values:Self) -> Self
    {
        .zip(padding: arrays, with: values)
    }
    @inlinable public static
    func zip(padding arrays:[Self], with values:Self) -> Self
    {
        .document
        {
            $0["$zip"] = .init
            {
                $0["inputs"] = arrays
                $0["useLongestLength"] = true
                $0["defaults"] = values
            }
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func filter(_ array:Self, where predicate:Self, limit:Self, as binding:String?) -> Self
    {
        .document
        {
            $0["$filter"] = .init
            {
                $0["input"] = array
                $0["limit"] = limit
                $0["cond"] = predicate
                $0["as"] = binding
            }
        }
    }

    @inlinable public static
    func map(_ array:Self, as binding:String?, in transform:Self) -> Self
    {
        .document
        {
            $0["$map"] = .init
            {
                $0["input"] = array
                $0["as"] = binding
                $0["in"] = transform
            }
        }
    }

    @inlinable public static
    func reduce(_ array:Self, from initialValue:Self, combine:Self) -> Self
    {
        .document
        {
            $0["$reduce"] = .init
            {
                $0["input"] = array
                $0["initialValue"] = initialValue
                $0["in"] = combine
            }
        }
    }
}
