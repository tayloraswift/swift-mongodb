import BSONUnions

extension BSON
{
    struct KeyedDecoder<Bytes, Key> where Bytes:RandomAccessCollection<UInt8>, Key:CodingKey
    {
        let codingPath:[any CodingKey]
        let allKeys:[Key]
        let items:[String: AnyBSON<Bytes>]
        
        init(_ dictionary:BSON.Dictionary<Bytes>, path:[any CodingKey]) 
        {
            self.codingPath = path
            self.items = dictionary.items
            self.allKeys = self.items.keys.compactMap(Key.init(stringValue:))
        }
    }
}
extension BSON.KeyedDecoder
{
    public
    func contains(_ key:Key) -> Bool 
    {
        self.items.keys.contains(key.stringValue)
    }
    // local `Key` type may be different from the dictionary’s `Key` type
    func diagnose<T>(_ key:some CodingKey,
        _ decode:(AnyBSON<Bytes>) throws -> T?) throws -> T
    {
        var path:[any CodingKey]
        { 
            self.codingPath + CollectionOfOne<any CodingKey>.init(key) 
        }
        guard let value:AnyBSON<Bytes> = self.items[key.stringValue]
        else 
        {
            let context:DecodingError.Context = .init(codingPath: path, 
                debugDescription: "key '\(key)' not found")
            throw DecodingError.keyNotFound(key, context)
        }
        do 
        {
            if let decoded:T = try decode(value)
            {
                return decoded
            }

            throw DecodingError.init(annotating: BSON.TypecastError<T>.init(
                    invalid: value.type),
                initializing: T.self,
                path: path)
        }
        catch let error
        {
            throw DecodingError.init(annotating: error,
                initializing: T.self,
                path: path)
        }
    }
}

extension BSON.KeyedDecoder:KeyedDecodingContainerProtocol 
{
    public
    func decode<T>(_:T.Type, forKey key:Key) throws -> T where T:Decodable
    {
        return try .init(from: try self.singleValueContainer(forKey: key))
    }
    func decodeNil(forKey key:Key) throws -> Bool
    {
        try self.diagnose(key) { $0.null != nil }
    }
    public
    func decode(_:Bool.Type, forKey key:Key) throws -> Bool
    {
        try self.diagnose(key) { $0.as(Bool.self) }
    }
    public
    func decode(_:Float.Type, forKey key:Key) throws -> Float
    {
        try self.diagnose(key) { $0.as(Float.self) }
    }
    public
    func decode(_:Double.Type, forKey key:Key) throws -> Double
    {
        try self.diagnose(key) { $0.as(Double.self) }
    }
    public
    func decode(_:String.Type, forKey key:Key) throws -> String
    {
        try self.diagnose(key) { $0.as(String.self) }
    }
    public
    func decode(_:Int.Type, forKey key:Key) throws -> Int
    {
        try self.diagnose(key) { try $0.as(Int.self) }
    }
    public
    func decode(_:Int64.Type, forKey key:Key) throws -> Int64
    {
        try self.diagnose(key) { try $0.as(Int64.self) }
    }
    public
    func decode(_:Int32.Type, forKey key:Key) throws -> Int32
    {
        try self.diagnose(key) { try $0.as(Int32.self) }
    }
    public
    func decode(_:Int16.Type, forKey key:Key) throws -> Int16
    {
        try self.diagnose(key) { try $0.as(Int16.self) }
    }
    public
    func decode(_:Int8.Type, forKey key:Key) throws -> Int8
    {
        try self.diagnose(key) { try $0.as(Int8.self) }
    }
    public
    func decode(_:UInt.Type, forKey key:Key) throws -> UInt
    {
        try self.diagnose(key) { try $0.as(UInt.self) }
    }
    public
    func decode(_:UInt64.Type, forKey key:Key) throws -> UInt64
    {
        try self.diagnose(key) { try $0.as(UInt64.self) }
    }
    public
    func decode(_:UInt32.Type, forKey key:Key) throws -> UInt32
    {
        try self.diagnose(key) { try $0.as(UInt32.self) }
    }
    public
    func decode(_:UInt16.Type, forKey key:Key) throws -> UInt16
    {
        try self.diagnose(key) { try $0.as(UInt16.self) }
    }
    public
    func decode(_:UInt8.Type, forKey key:Key) throws -> UInt8
    {
        try self.diagnose(key) { try $0.as(UInt8.self) }
    }
    
    func superDecoder() throws -> any Decoder
    {
        try self.singleValueContainer(forKey: Super.super, typed: Super.self)
    }
    public 
    func superDecoder(forKey key:Key) throws -> any Decoder
    {
        try self.singleValueContainer(forKey: key) as any Decoder
    }
    
    public 
    func singleValueContainer<Key>(forKey key:Key,
        typed _:Key.Type = Key.self) throws -> BSON.SingleValueDecoder<Bytes>
        where Key:CodingKey
    {
        let value:AnyBSON<Bytes> = try self.diagnose(key){ $0 }
        let decoder:BSON.SingleValueDecoder<Bytes> = .init(value, 
            path: self.codingPath + CollectionOfOne<any CodingKey>.init(key))
        return decoder
    }
    public 
    func nestedUnkeyedContainer(forKey key:Key) throws -> UnkeyedDecodingContainer
    {
        let path:[any CodingKey] = self.codingPath + CollectionOfOne<any CodingKey>.init(key)
        let container:BSON.UnkeyedDecoder<Bytes.SubSequence> =
            .init(try self.diagnose(key) { try $0.array() }, path: path)
        return container as UnkeyedDecodingContainer
    }
    public 
    func nestedContainer<NestedKey>(keyedBy _:NestedKey.Type,
        forKey key:Key) throws -> KeyedDecodingContainer<NestedKey>
    {
        let path:[any CodingKey] = self.codingPath + CollectionOfOne<any CodingKey>.init(key)
        let container:BSON.KeyedDecoder<Bytes.SubSequence, NestedKey> =
            .init(try self.diagnose(key) { try $0.dictionary() }, path: path)
        return .init(container)
    }
}
