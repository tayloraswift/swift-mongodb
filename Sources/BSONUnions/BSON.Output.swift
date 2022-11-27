import BSON

extension BSON.Output
{
    /// Serializes the given variant value, without encoding its type.
    @inlinable public mutating
    func serialize(variant:AnyBSON<some RandomAccessCollection<UInt8>>)
    {
        switch variant
        {
        case .double(let double):
            self.serialize(integer: double.bitPattern)
        
        case .string(let string):
            self.serialize(utf8: string)
        
        case .document(let document):
            self.serialize(document: document)

        case .tuple(let tuple):
            self.serialize(tuple: tuple)

        case .binary(let binary):
            self.serialize(binary: binary)
        
        case .null:
            break
        
        case .id(let id):
            self.serialize(id: id)
        
        case .bool(let bool):
            self.append(bool ? 1 : 0)

        case .millisecond(let millisecond):
            self.serialize(integer: millisecond.value)
        
        case .regex(let regex):
            self.serialize(key: regex.pattern)
            self.serialize(key: regex.options.description)
        
        case .pointer(let database, let id):
            self.serialize(utf8: database)
            self.serialize(id: id)
        
        case .javascript(let code):
            self.serialize(utf8: code)
        
        case .javascriptScope(let scope, let code):
            let size:Int32 = 4 + Int32.init(scope.size) + Int32.init(code.size)
            self.serialize(integer: size)
            self.serialize(utf8: code)
            self.serialize(document: scope)
        
        case .int32(let int32):
            self.serialize(integer: int32)
        
        case .uint64(let uint64):
            self.serialize(integer: uint64)
        
        case .int64(let int64):
            self.serialize(integer: int64)

        case .decimal128(let decimal):
            self.serialize(integer: decimal.low)
            self.serialize(integer: decimal.high)
        
        case .max:
            break
        case .min:
            break
        }
    }
    /// Serializes the raw type code of the given variant value, followed by
    /// the field key (with a trailing null byte), followed by the variant value
    /// itself.
    @inlinable public mutating
    func serialize(key:String, value:AnyBSON<some RandomAccessCollection<UInt8>>)
    {
        self.serialize(type: value.type)
        self.serialize(key: key)
        self.serialize(variant: value)
    }
    @inlinable public mutating
    func serialize<Bytes>(fields:some Sequence<(key:String, value:AnyBSON<Bytes>)>)
        where Bytes:RandomAccessCollection<UInt8>
    {
        for (key, value):(String, AnyBSON<Bytes>) in fields
        {
            self.serialize(key: key, value: value)
        }
    }
}
