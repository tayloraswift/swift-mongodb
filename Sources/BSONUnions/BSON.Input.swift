import BSON

extension BSON.Input
{
    /// Parses a variant BSON value, assuming it is of the specified `variant` type.
    @inlinable public mutating
    func parse(variant:BSON) throws -> AnyBSON<Source.SubSequence>
    {
        switch variant
        {
        case .double:
            return .double(.init(bitPattern: try self.parse(as: UInt64.self)))
        
        case .string:
            return .string(try self.parse(as: BSON.UTF8<Source.SubSequence>.self))
        
        case .document:
            return .document(try self.parse(as: BSON.Document<Source.SubSequence>.self))
        
        case .tuple:
            return .tuple(try self.parse(as: BSON.Tuple<Source.SubSequence>.self))
        
        case .binary:
            return .binary(try self.parse(as: BSON.Binary<Source.SubSequence>.self))
        
        case .null:
            return .null
        
        case .id:
            return .id(try self.parse(as: BSON.Identifier.self))
        
        case .bool:
            return .bool(try self.parse(as: Bool.self))
        
        case .millisecond:
            return .millisecond(try self.parse(as: BSON.Millisecond.self))
        
        case .regex:
            return .regex(try self.parse(as: BSON.Regex.self))
        
        case .pointer:
            let database:BSON.UTF8<Source.SubSequence> = try self.parse(
                as: BSON.UTF8<Source.SubSequence>.self)
            let object:BSON.Identifier = try self.parse(
                as: BSON.Identifier.self)
            return .pointer(database, object)
        
        case .javascript:
            return .javascript(try self.parse(as: BSON.UTF8<Source.SubSequence>.self))
        
        case .javascriptScope:
            // possible micro-optimization here
            let _:Int32 = try self.parse(as: Int32.self)
            let code:BSON.UTF8<Source.SubSequence> = 
                try self.parse(as: BSON.UTF8<Source.SubSequence>.self)
            let scope:BSON.Document<Source.SubSequence> = 
                try self.parse(as: BSON.Document<Source.SubSequence>.self)
            return .javascriptScope(scope, code)
        
        case .int32:
            return .int32(try self.parse(as: Int32.self))
        
        case .uint64:
            return .uint64(try self.parse(as: UInt64.self))
        
        case .int64:
            return .int64(try self.parse(as: Int64.self))
        
        case .decimal128:
            return .decimal128(try self.parse(as: BSON.Decimal128.self))
        
        case .max:
            return .max
        case .min:
            return .min
        }
    }
}
