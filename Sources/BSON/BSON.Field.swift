extension BSON
{
    /// A type that can serialize any BSON container element.
    @frozen public
    struct Field
    {
        public
        let key:String
        public
        var output:BSON.Output<[UInt8]>

        @inlinable public
        init(key:String, output:BSON.Output<[UInt8]>)
        {
            self.key = key
            self.output = output
        }
    }
}
extension BSON.Field
{
    @inlinable public mutating
    func encode(double:Double)
    {
        self.output.serialize(type: .double)
        self.output.serialize(key: self.key)
        self.output.serialize(integer: double.bitPattern)
    }
    @inlinable public mutating
    func encode(null:Void)
    {
        self.output.serialize(type: .null)
        self.output.serialize(key: self.key)
    }
    @inlinable public mutating
    func encode(id:BSON.Identifier)
    {
        self.output.serialize(type: .id)
        self.output.serialize(key: self.key)
        self.output.serialize(id: id)
    }
    @inlinable public mutating
    func encode(bool:Bool)
    {
        self.output.serialize(type: .bool)
        self.output.serialize(key: self.key)
        self.output.append(bool ? 1 : 0)
    }
    @inlinable public mutating
    func encode(millisecond:BSON.Millisecond)
    {
        self.output.serialize(type: .millisecond)
        self.output.serialize(key: self.key)
        self.output.serialize(integer: millisecond.value)
    }
    @inlinable public mutating
    func encode(regex:BSON.Regex)
    {
        self.output.serialize(type: .regex)
        self.output.serialize(key: self.key)
        self.output.serialize(key: regex.pattern)
        self.output.serialize(key: regex.options.description)
    }
    @inlinable public mutating
    func encode(int32:Int32)
    {
        self.output.serialize(type: .int32)
        self.output.serialize(key: self.key)
        self.output.serialize(integer: int32)
    }
    @inlinable public mutating
    func encode(uint64:UInt64)
    {
        self.output.serialize(type: .uint64)
        self.output.serialize(key: self.key)
        self.output.serialize(integer: uint64)
    }
    @inlinable public mutating
    func encode(int64:Int64)
    {
        self.output.serialize(type: .int64)
        self.output.serialize(key: self.key)
        self.output.serialize(integer: int64)
    }
    @inlinable public mutating
    func encode(decimal128:BSON.Decimal128)
    {
        self.output.serialize(type: .decimal128)
        self.output.serialize(key: self.key)
        self.output.serialize(integer: decimal128.low)
        self.output.serialize(integer: decimal128.high)
    }
    @inlinable public mutating
    func encode(max:BSON.Max)
    {
        self.output.serialize(type: .max)
        self.output.serialize(key: self.key)
    }
    @inlinable public mutating
    func encode(min:BSON.Min)
    {
        self.output.serialize(type: .min)
        self.output.serialize(key: self.key)
    }

    @inlinable public mutating
    func encode(binary:BSON.BinaryView<some RandomAccessCollection<UInt8>>)
    {
        self.output.serialize(type: .binary)
        self.output.serialize(key: self.key)
        self.output.serialize(binary: binary)
    }

    @inlinable public mutating
    func encode(document:BSON.DocumentView<some RandomAccessCollection<UInt8>>)
    {
        self.output.serialize(type: .document)
        self.output.serialize(key: self.key)
        self.output.serialize(document: document)
    }
    @inlinable public mutating
    func encode(list:BSON.ListView<some RandomAccessCollection<UInt8>>)
    {
        self.output.serialize(type: .list)
        self.output.serialize(key: self.key)
        self.output.serialize(list: list)
    }

    @inlinable public mutating
    func encode(string:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self.output.serialize(type: .string)
        self.output.serialize(key: self.key)
        self.output.serialize(utf8: string)
    }
    @inlinable public mutating
    func encode(javascript:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self.output.serialize(type: .javascript)
        self.output.serialize(key: self.key)
        self.output.serialize(utf8: javascript)
    }
}
extension BSON.Field
{
    @inlinable public mutating
    func frame(_ type:BSON, then finish:(inout BSON.Output<[UInt8]>) -> ())
    {
        self.output.serialize(type: type)
        self.output.serialize(key: self.key)
        self.output.frame(finish)
    }
}
