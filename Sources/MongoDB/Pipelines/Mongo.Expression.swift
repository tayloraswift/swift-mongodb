import BSONSchema
import BSONUnions

extension Mongo
{
    public
    enum Expression:Sendable
    {
        case document(BSON.Fields)
        case tuple(BSON.Elements)

        case bool(Bool)
        case decimal128(BSON.Decimal128)
        case double(Double)
        case int(Int)
        case max
        case min

        /// A field path. The string payload can contain path separators (`.`),
        /// but it should not contain the leading dollar sign (`$`) that is
        /// prefixed to it when it appears inline in a BSON document.
        ///
        /// To specify an absolute path, use the `$$ROOT` system variable,
        /// keeping the inner dollar sign (`$`).
        ///
        /// ```swift
        /// let absolute:Expression = .field("$ROOT.example")
        /// ```
        ///
        /// The `$$CURRENT` system variable can also be used this way, but there
        /// is rarely reason to, because field path expressions are relative to
        /// `$$CURRENT` by default.
        case field(String)

        case CLUSTER_TIME
        case DESCEND
        case KEEP
        case PRUNE
        case NOW
        case REMOVE
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func document(_ populate:(inout BSON.Fields) throws -> ()) rethrows -> Self
    {
        .document(try .init(with: populate))
    }
    @inlinable public static
    func tuple(_ populate:(inout BSON.Elements) throws -> ()) rethrows -> Self
    {
        .tuple(try .init(with: populate))
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
    init(integerLiteral:Int)
    {
        self = .int(integerLiteral)
    }
}
extension Mongo.Expression:BSONDecodable
{
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast
        {
            let string:String
            switch $0
            {
            case .document(let document):
                return .document(.init(bson: document))

            case .tuple(let tuple):
                return .tuple(.init(bson: tuple))
            
            case .bool(let bool):
                return .bool(bool)
            
            case .decimal128(let decimal):
                return .decimal128(decimal)
            
            case .double(let double):
                return .double(double)
            
            case .int32(let int32):
                return .int(.init(int32))

            case .int64(let int64):
                guard let int:Int = .init(exactly: int64)
                else
                {
                    throw BSON.IntegerOverflowError<Int>.int64(int64)
                }
                return .int(int)
                        
            case .max:
                return .max
            
            case .min:
                return .min

            case .string(let utf8):
                string = .init(bson: utf8)
            
            case _:
                return nil
            }
            switch string
            {
            case "$$CLUSTER_TIME":  return .CLUSTER_TIME
            case "$$DESCEND":       return .DESCEND
            case "$$KEEP":          return .KEEP
            case "$$PRUNE":         return .PRUNE
            case "$$NOW":           return .NOW
            case "$$REMOVE":        return .REMOVE
            case _:                 break
            }
            if case "$"? = string.first
            {
                return .field(.init(string.dropFirst()))
            }
            else
            {
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
        let string:String
        switch self
        {
        case .document(let document):
            document.encode(to: &field)
            return
        case .tuple(let tuple):
            tuple.encode(to: &field)
            return
        
        case .bool(let bool):
            bool.encode(to: &field)
            return
        
        case .decimal128(let decimal):
            decimal.encode(to: &field)
            return
        
        case .double(let double):
            double.encode(to: &field)
            return
        
        case .int(let int):
            int.encode(to: &field)
            return
        
        case .max:
            BSON.Max.init().encode(to: &field)
            return
        
        case .min:
            BSON.Min.init().encode(to: &field)
            return
        
        
        case .field(let path):  string = "$\(path)"

        case .CLUSTER_TIME:     string = "$$CLUSTER_TIME"
        case .DESCEND:          string = "$$DESCEND"
        case .KEEP:             string = "$$KEEP"
        case .PRUNE:            string = "$$PRUNE"
        case .NOW:              string = "$$NOW"
        case .REMOVE:           string = "$$REMOVE"
        }

        string.encode(to: &field)
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
}
extension Mongo.Expression
{
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
}
extension Mongo.Expression
{
    @inlinable public static
    func ceil(_ expression:Self) -> Self
    {
        .document
        {
            $0["$ceil"] = expression
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func divide(_ dividend:Self, by divisor:Self) -> Self
    {
        .document
        {
            $0["$divide"] = [dividend, divisor]
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func exp(_ expression:Self) -> Self
    {
        .document
        {
            $0["$exp"] = expression
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func floor(_ expression:Self) -> Self
    {
        .document
        {
            $0["$floor"] = expression
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func ln(_ expression:Self) -> Self
    {
        .document
        {
            $0["$ln"] = expression
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func log(base:Self, _ expression:Self) -> Self
    {
        .document
        {
            // note: order of arguments is reversed!
            $0["$log"] = [expression, base]
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func log10(_ expression:Self) -> Self
    {
        .document
        {
            $0["$log10"] = expression
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func mod(_ dividend:Self, by divisor:Self) -> Self
    {
        .document
        {
            $0["$mod"] = [dividend, divisor]
        }
    }
}
extension Mongo.Expression
{
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
}
extension Mongo.Expression
{
    @inlinable public static
    func pow(base:Self, _ expression:Self) -> Self
    {
        .document
        {
            $0["$pow"] = [base, expression]
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func round(_ expression:Self, places:Self = 0) -> Self
    {
        .document
        {
            $0["$round"] = [expression, places]
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func sqrt(_ expression:Self) -> Self
    {
        .document
        {
            $0["$sqrt"] = expression
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func subtract(_ minuend:Self, minus subtrahend:Self) -> Self
    {
        .document
        {
            $0["$subtract"] = [minuend, subtrahend]
        }
    }
}
extension Mongo.Expression
{
    @inlinable public static
    func trunc(_ expression:Self, places:Self = 0) -> Self
    {
        .document
        {
            $0["$trunc"] = [expression, places]
        }
    }
}
