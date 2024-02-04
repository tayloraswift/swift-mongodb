extension BSON
{
    /// A single-value decoding container, for use with compiler-generated ``Decodable``
    /// implementations.
    public
    struct SingleValueDecoder
    {
        let value:BSON.AnyValue
        public
        let codingPath:[any CodingKey]
        public
        let userInfo:[CodingUserInfoKey: Any]

        public
        init(_ value:BSON.AnyValue,
            path:[any CodingKey],
            userInfo:[CodingUserInfoKey: Any] = [:])
        {
            self.value = value
            self.codingPath = path
            self.userInfo = userInfo
        }
    }
}
extension BSON.SingleValueDecoder
{
    func diagnose<T>(_ decode:(BSON.AnyValue) throws -> T?) throws -> T
    {
        do
        {
            if let decoded:T = try decode(value)
            {
                return decoded
            }

            throw DecodingError.init(annotating: BSON.TypecastError<T>.init(
                    invalid: value.type),
                initializing: T.self,
                path: self.codingPath)
        }
        catch let error
        {
            throw DecodingError.init(annotating: error,
                initializing: T.self,
                path: self.codingPath)
        }
    }
}
extension BSON.SingleValueDecoder:Decoder
{
    public
    func singleValueContainer() -> any SingleValueDecodingContainer
    {
        self as any SingleValueDecodingContainer
    }
    public
    func unkeyedContainer() throws -> any UnkeyedDecodingContainer
    {
        BSON.UnkeyedDecoder.init(try self.diagnose { try .init(parsing: $0) },
            path: self.codingPath) as any UnkeyedDecodingContainer
    }
    public
    func container<Key>(keyedBy _:Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key:CodingKey
    {
        let container:BSON.KeyedDecoder<Key> =
            .init(try self.diagnose { try .init(parsing: $0) }, path: self.codingPath)
        return .init(container)
    }
}

extension BSON.SingleValueDecoder:SingleValueDecodingContainer
{
    public
    func decode<T>(_:T.Type) throws -> T where T:Decodable
    {
        try .init(from: self)
    }
    public
    func decodeNil() -> Bool
    {
        self.value.as(BSON.Null.self) != nil
    }
    public
    func decode(_:Bool.Type) throws -> Bool
    {
        try self.diagnose { $0.as(Bool.self) }
    }
    public
    func decode(_:Float.Type) throws -> Float
    {
        try self.diagnose { $0.as(Float.self) }
    }
    public
    func decode(_:Double.Type) throws -> Double
    {
        try self.diagnose { $0.as(Double.self) }
    }
    public
    func decode(_:String.Type) throws -> String
    {
        try self.diagnose { $0.as(String.self) }
    }
    public
    func decode(_:Int.Type) throws -> Int
    {
        try self.diagnose { try $0.as(Int.self) }
    }
    public
    func decode(_:Int64.Type) throws -> Int64
    {
        try self.diagnose { try $0.as(Int64.self) }
    }
    public
    func decode(_:Int32.Type) throws -> Int32
    {
        try self.diagnose { try $0.as(Int32.self) }
    }
    public
    func decode(_:Int16.Type) throws -> Int16
    {
        try self.diagnose { try $0.as(Int16.self) }
    }
    public
    func decode(_:Int8.Type) throws -> Int8
    {
        try self.diagnose { try $0.as(Int8.self) }
    }
    public
    func decode(_:UInt.Type) throws -> UInt
    {
        try self.diagnose { try $0.as(UInt.self) }
    }
    public
    func decode(_:UInt64.Type) throws -> UInt64
    {
        try self.diagnose { try $0.as(UInt64.self) }
    }
    public
    func decode(_:UInt32.Type) throws -> UInt32
    {
        try self.diagnose { try $0.as(UInt32.self) }
    }
    public
    func decode(_:UInt16.Type) throws -> UInt16
    {
        try self.diagnose { try $0.as(UInt16.self) }
    }
    public
    func decode(_:UInt8.Type) throws -> UInt8
    {
        try self.diagnose { try $0.as(UInt8.self) }
    }
}
