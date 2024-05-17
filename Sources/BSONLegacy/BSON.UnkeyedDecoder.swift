import BSON

extension BSON
{
    struct UnkeyedDecoder
    {
        public
        let codingPath:[any CodingKey]
        public
        var currentIndex:Int
        let elements:[BSON.AnyValue]

        public
        init(_ array:BSON.ListDecoder, path:[any CodingKey])
        {
            self.codingPath     = path
            self.elements       = array.elements
            self.currentIndex   = self.elements.startIndex
        }
    }
}
extension BSON.UnkeyedDecoder
{
    public
    var count:Int?
    {
        self.elements.count
    }
    public
    var isAtEnd:Bool
    {
        self.currentIndex >= self.elements.endIndex
    }

    mutating
    func diagnose<T>(_ decode:(BSON.AnyValue) throws -> T?) throws -> T
    {
        let key:Index = .init(intValue: self.currentIndex)
        var path:[any CodingKey]
        {
            self.codingPath + CollectionOfOne<any CodingKey>.init(key)
        }

        if self.isAtEnd
        {
            let context:DecodingError.Context = .init(codingPath: path,
                debugDescription: "index (\(self.currentIndex)) out of range")
            throw DecodingError.keyNotFound(key, context)
        }

        let value:BSON.AnyValue = self.elements[self.currentIndex]
        self.currentIndex += 1
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

extension BSON.UnkeyedDecoder:UnkeyedDecodingContainer
{
    public mutating
    func decode<T>(_:T.Type) throws -> T where T:Decodable
    {
        try .init(from: try self.singleValueContainer())
    }
    public mutating
    func decodeNil() throws -> Bool
    {
        try self.diagnose { $0.as(BSON.Null.self) != nil }
    }
    public mutating
    func decode(_:Bool.Type) throws -> Bool
    {
        try self.diagnose { $0.as(Bool.self) }
    }
    public mutating
    func decode(_:Float.Type) throws -> Float
    {
        try self.diagnose { $0.as(Float.self) }
    }
    public mutating
    func decode(_:Double.Type) throws -> Double
    {
        try self.diagnose { $0.as(Double.self) }
    }
    public mutating
    func decode(_:String.Type) throws -> String
    {
        try self.diagnose { $0.as(String.self) }
    }
    public mutating
    func decode(_:Int.Type) throws -> Int
    {
        try self.diagnose { try $0.as(Int.self) }
    }
    public mutating
    func decode(_:Int64.Type) throws -> Int64
    {
        try self.diagnose { try $0.as(Int64.self) }
    }
    public mutating
    func decode(_:Int32.Type) throws -> Int32
    {
        try self.diagnose { try $0.as(Int32.self) }
    }
    public mutating
    func decode(_:Int16.Type) throws -> Int16
    {
        try self.diagnose { try $0.as(Int16.self) }
    }
    public mutating
    func decode(_:Int8.Type) throws -> Int8
    {
        try self.diagnose { try $0.as(Int8.self) }
    }
    public mutating
    func decode(_:UInt.Type) throws -> UInt
    {
        try self.diagnose { try $0.as(UInt.self) }
    }
    public mutating
    func decode(_:UInt64.Type) throws -> UInt64
    {
        try self.diagnose { try $0.as(UInt64.self) }
    }
    public mutating
    func decode(_:UInt32.Type) throws -> UInt32
    {
        try self.diagnose { try $0.as(UInt32.self) }
    }
    public mutating
    func decode(_:UInt16.Type) throws -> UInt16
    {
        try self.diagnose { try $0.as(UInt16.self) }
    }
    public mutating
    func decode(_:UInt8.Type) throws -> UInt8
    {
        try self.diagnose { try $0.as(UInt8.self) }
    }

    public mutating
    func superDecoder() throws -> any Decoder
    {
        try self.singleValueContainer() as any Decoder
    }
    public mutating
    func singleValueContainer() throws -> BSON.SingleValueDecoder
    {
        let key:Index = .init(intValue: self.currentIndex)
        let value:BSON.AnyValue = try self.diagnose { $0 }
        let decoder:BSON.SingleValueDecoder = .init(value,
            path: self.codingPath + CollectionOfOne<any CodingKey>.init(key))
        return decoder
    }
    public mutating
    func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer
    {
        let path:[any CodingKey] = self.codingPath +
            CollectionOfOne<any CodingKey>.init(Index.init(intValue: self.currentIndex))
        let container:BSON.UnkeyedDecoder =
            .init(try self.diagnose { try .init(parsing: $0) }, path: path)
        return container as any UnkeyedDecodingContainer
    }
    public mutating
    func nestedContainer<NestedKey>(keyedBy _:NestedKey.Type)
        throws -> KeyedDecodingContainer<NestedKey>
    {
        let path:[any CodingKey] = self.codingPath +
            CollectionOfOne<any CodingKey>.init(Index.init(intValue: self.currentIndex))
        let container:BSON.KeyedDecoder<NestedKey> =
            .init(try self.diagnose { try .init(parsing: $0) }, path: path)
        return .init(container)
    }
}
