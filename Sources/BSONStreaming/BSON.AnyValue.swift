import BSONTypes

extension BSON.AnyValue:ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByExtendedGraphemeClusterLiteral, 
    ExpressibleByUnicodeScalarLiteral,
    ExpressibleByDictionaryLiteral
    where   Bytes:RangeReplaceableCollection<UInt8>,
            Bytes:RandomAccessCollection<UInt8>,
            Bytes.Index == Int
{
    @inlinable public
    init(stringLiteral:String)
    {
        self = .string(.init(from: stringLiteral))
    }
    @inlinable public
    init(arrayLiteral:Self...)
    {
        self = .list(.init(elements: arrayLiteral))
    }
    @inlinable public
    init(dictionaryLiteral:(BSON.Key, Self)...)
    {
        self = .document(.init(fields: dictionaryLiteral))
    }
}

extension BSON.AnyValue:ExpressibleByFloatLiteral
{
    @inlinable public
    init(floatLiteral:Double)
    {
        self = .double(floatLiteral)
    }
}
extension BSON.AnyValue:ExpressibleByIntegerLiteral
{
    /// Creates an instance initialized to the specified integer value.
    ///
    /// Although MongoDB uses ``Int32`` as its default integer type,
    /// this library infers integer literals to be of type ``Int`` for
    /// consistency with the rest of the Swift language.
    @inlinable public
    init(integerLiteral:Int)
    {
        self = .int64(Int64.init(integerLiteral))
    }
}
extension BSON.AnyValue:ExpressibleByBooleanLiteral
{
    @inlinable public
    init(booleanLiteral:Bool)
    {
        self = .bool(booleanLiteral)
    }
}

