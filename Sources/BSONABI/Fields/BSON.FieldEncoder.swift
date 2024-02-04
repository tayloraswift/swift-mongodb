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
    @inlinable public mutating
    func encode(double:Double)
    {
        self[.double].serialize(integer: double.bitPattern)
    }
    @inlinable public mutating
    func encode(id:BSON.Identifier)
    {
        self[.id].serialize(id: id)
    }
    @inlinable public mutating
    func encode(bool:Bool)
    {
        self[.bool].append(bool ? 1 : 0)
    }
    @inlinable public mutating
    func encode(millisecond:BSON.Millisecond)
    {
        self[.millisecond].serialize(integer: millisecond.value)
    }
    @inlinable public mutating
    func encode(regex:BSON.Regex)
    {
        {
            $0.serialize(cString: regex.pattern)
            $0.serialize(cString: regex.options.description)
        } (&self[.regex])
    }
    @inlinable public mutating
    func encode(int32:Int32)
    {
        self[.int32].serialize(integer: int32)
    }
    @inlinable public mutating
    func encode(uint64:UInt64)
    {
        self[.uint64].serialize(integer: uint64)
    }
    @inlinable public mutating
    func encode(int64:Int64)
    {
        self[.int64].serialize(integer: int64)
    }
    @inlinable public mutating
    func encode(decimal128:BSON.Decimal128)
    {
        {
            $0.serialize(integer: decimal128.low)
            $0.serialize(integer: decimal128.high)
        } (&self[.decimal128])
    }
    @inlinable public mutating
    func encode(max:BSON.Max)
    {
        self[.max] as Void
    }
    @inlinable public mutating
    func encode(min:BSON.Min)
    {
        self[.min] as Void
    }
    @inlinable public mutating
    func encode(null:BSON.Null)
    {
        self[.null] as Void
    }

    @inlinable public mutating
    func encode(binary:BSON.BinaryView<some RandomAccessCollection<UInt8>>)
    {
        self[.binary].serialize(binary: binary)
    }

    @inlinable public mutating
    func encode(document:BSON.DocumentView)
    {
        self[.document].serialize(document: document)
    }
    @inlinable public mutating
    func encode(list:BSON.ListView)
    {
        self[.list].serialize(list: list)
    }

    @inlinable public mutating
    func encode(string:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self[.string].serialize(utf8: string)
    }
    @inlinable public mutating
    func encode(javascript:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self[.javascript].serialize(utf8: javascript)
    }
}
extension BSON.FieldEncoder
{
    @inlinable internal
    subscript(type:BSON.AnyType) -> Void
    {
        mutating get
        {
            self.output.serialize(type: type)
            self.output.serialize(cString: self.key.rawValue)
        }
    }
    @inlinable internal
    subscript(type:BSON.AnyType) -> BSON.Output
    {
        mutating get
        {
            self[type] as Void
            return self.output
        }
        _modify
        {
            self[type] as Void
            yield &self.output
        }
    }
}
extension BSON.FieldEncoder
{
    /// Writes the stored type code and ``key`` to the output buffer, temporarily rebinds
    /// the output’s storage buffer to an encoder of the specified type, and brackets any
    /// newly-written bytes with the appropriate headers or trailers, if performing a
    /// mutation. The getter has no effect.
    @inlinable public
    subscript<Encoder>(as _:Encoder.Type = Encoder.self) -> Encoder where Encoder:BSON.Encoder
    {
        get
        {
            self.output[in: BSON.DocumentFrame.self][as: Encoder.self]
        }
        _modify
        {
            yield &self[Encoder.type][in: BSON.DocumentFrame.self][as: Encoder.self]
        }
    }
}
