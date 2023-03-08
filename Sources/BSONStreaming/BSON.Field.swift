import BSONTypes
import BSONTraversal

extension BSON
{
    /// A type that can serialize any BSON container element.
    @frozen public
    struct Field
    {
        public
        let key:Key
        public
        var output:BSON.Output<[UInt8]>

        @inlinable public
        init(key:Key, output:BSON.Output<[UInt8]>)
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
        self.emit(.double)
        {
            $0.serialize(integer: double.bitPattern)
        }
    }
    @inlinable public mutating
    func encode(null:Void)
    {
        self.emit(.null)
    }
    @inlinable public mutating
    func encode(id:BSON.Identifier)
    {
        self.emit(.id)
        {
            $0.serialize(id: id)
        }
    }
    @inlinable public mutating
    func encode(bool:Bool)
    {
        self.emit(.bool)
        {
            $0.append(bool ? 1 : 0)
        }
    }
    @inlinable public mutating
    func encode(millisecond:BSON.Millisecond)
    {
        self.emit(.millisecond)
        {
            $0.serialize(integer: millisecond.value)
        }
    }
    @inlinable public mutating
    func encode(regex:BSON.Regex)
    {
        self.emit(.regex)
        {
            $0.serialize(cString: regex.pattern)
            $0.serialize(cString: regex.options.description)
        }
    }
    @inlinable public mutating
    func encode(int32:Int32)
    {
        self.emit(.int32)
        {
            $0.serialize(integer: int32)
        }
    }
    @inlinable public mutating
    func encode(uint64:UInt64)
    {
        self.emit(.uint64)
        {
            $0.serialize(integer: uint64)
        }
    }
    @inlinable public mutating
    func encode(int64:Int64)
    {
        self.emit(.int64)
        {
            $0.serialize(integer: int64)
        }
    }
    @inlinable public mutating
    func encode(decimal128:BSON.Decimal128)
    {
        self.emit(.decimal128)
        {
            $0.serialize(integer: decimal128.low)
            $0.serialize(integer: decimal128.high)
        }
    }
    @inlinable public mutating
    func encode(max:BSON.Max)
    {
        self.emit(.max)
    }
    @inlinable public mutating
    func encode(min:BSON.Min)
    {
        self.emit(.min)
    }

    @inlinable public mutating
    func encode(binary:BSON.BinaryView<some RandomAccessCollection<UInt8>>)
    {
        self.emit(.binary)
        {
            $0.serialize(binary: binary)
        }
    }

    @inlinable public mutating
    func encode(document:BSON.DocumentView<some RandomAccessCollection<UInt8>>)
    {
        self.emit(.document)
        {
            $0.serialize(document: document)
        }
    }
    @inlinable public mutating
    func encode(list:BSON.ListView<some RandomAccessCollection<UInt8>>)
    {
        self.emit(.list)
        {
            $0.serialize(list: list)
        }
    }

    @inlinable public mutating
    func encode(string:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self.emit(.string)
        {
            $0.serialize(utf8: string)
        }
    }
    @inlinable public mutating
    func encode(javascript:BSON.UTF8View<some BidirectionalCollection<UInt8>>)
    {
        self.emit(.javascript)
        {
            $0.serialize(utf8: javascript)
        }
    }
}
extension BSON.Field
{
    @inlinable internal mutating
    func emit(_ type:BSON)
    {
        self.output.serialize(type: type)
        self.output.serialize(cString: self.key.rawValue)
    }
    @inlinable internal mutating
    func emit(_ type:BSON, then finish:(inout BSON.Output<[UInt8]>) -> ())
    {
        self.emit(type)
        finish(&self.output)
    }
    @inlinable public mutating
    func emit<Frame>(_ type:BSON, frame _:Frame.Type,
        around fill:(inout BSON.Output<[UInt8]>) -> ())
        where Frame:VariableLengthBSONFrame
    {
        self.emit(type)
        self.output.with(frame: Frame.self, do: fill)
    }
}
