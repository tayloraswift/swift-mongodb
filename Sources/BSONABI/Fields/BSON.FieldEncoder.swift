extension BSON
{
    @available(*, deprecated, renamed: "FieldEncoder")
    public
    typealias Field = BSON.FieldEncoder
}
extension BSON
{
    /// A type that can serialize any BSON container element.
    @frozen public
    struct FieldEncoder
    {
        public
        let key:Key
        public
        var output:BSON.Output

        @inlinable public
        init(key:Key, output:BSON.Output)
        {
            self.key = key
            self.output = output
        }
    }
}
extension BSON.FieldEncoder
{
    /// Writes the given metatype value and ``key`` to the output buffer.
    @inlinable mutating
    func begin(_ type:BSON.AnyType)
    {
        self.output.serialize(type: type)
        self.output.serialize(cString: self.key.rawValue)
    }
}
extension BSON.FieldEncoder
{
    @inlinable public mutating
    func encode(double:Double)
    {
        self.begin(.double)
        self.output.serialize(integer: double.bitPattern)
    }
    @inlinable public mutating
    func encode(id:BSON.Identifier)
    {
        self.begin(.id)
        self.output.serialize(id: id)
    }
    @inlinable public mutating
    func encode(bool:Bool)
    {
        self.begin(.bool)
        self.output.append(bool ? 1 : 0)
    }
    @inlinable public mutating
    func encode(millisecond:BSON.Millisecond)
    {
        self.begin(.millisecond)
        self.output.serialize(integer: millisecond.value)
    }
    @inlinable public mutating
    func encode(regex:BSON.Regex)
    {
        self.begin(.regex)
        self.output.serialize(cString: regex.pattern)
        self.output.serialize(cString: regex.options.description)
    }
    @inlinable public mutating
    func encode(int32:Int32)
    {
        self.begin(.int32)
        self.output.serialize(integer: int32)
    }
    @inlinable public mutating
    func encode(timestamp:BSON.Timestamp)
    {
        self.begin(.timestamp)
        self.output.serialize(integer: timestamp.value)
    }
    @inlinable public mutating
    func encode(int64:Int64)
    {
        self.begin(.int64)
        self.output.serialize(integer: int64)
    }
    @inlinable public mutating
    func encode(decimal128:BSON.Decimal128)
    {
        self.begin(.decimal128)
        self.output.serialize(integer: decimal128.low)
        self.output.serialize(integer: decimal128.high)
    }
    @inlinable public mutating
    func encode(max:BSON.Max)
    {
        self.begin(.max)
    }
    @inlinable public mutating
    func encode(min:BSON.Min)
    {
        self.begin(.min)
    }
    @inlinable public mutating
    func encode(null:BSON.Null)
    {
        self.begin(.null)
    }

    @inlinable public mutating
    func encode(binary:BSON.BinaryView<some RandomAccessCollection<UInt8>>)
    {
        self.begin(.binary)
        self.output.serialize(binary: binary)
    }

    @inlinable public mutating
    func encode(document:BSON.Document)
    {
        self.begin(.document)
        self.output.serialize(document: document)
    }
    @inlinable public mutating
    func encode(list:BSON.List)
    {
        self.begin(.list)
        self.output.serialize(list: list)
    }

    @inlinable public mutating
    func encode(string:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self.begin(.string)
        self.output.serialize(utf8: string)
    }
    @inlinable public mutating
    func encode(javascript:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self.begin(.javascript)
        self.output.serialize(utf8: javascript)
    }
}
extension BSON.FieldEncoder
{
    /// Writes the stored type code and ``key`` to the output buffer, temporarily rebinds
    /// the output’s storage buffer to an encoder of the specified type, and brackets any
    /// newly-written bytes with the appropriate headers or trailers.
    ///
    /// A complete frame will always be written to the output buffer, even if the coroutine
    /// performs no writes.
    @inlinable public
    subscript<Encoder>(as _:Encoder.Type = Encoder.self) -> Encoder where Encoder:BSON.Encoder
    {
        mutating _read
        {
            self.begin(Encoder.frame.type)
            yield  self.output[in: Encoder.Frame.self][as: Encoder.self]
        }
        _modify
        {
            self.begin(Encoder.frame.type)
            yield &self.output[in: Encoder.Frame.self][as: Encoder.self]
        }
    }
}
