extension BSON
{
    @frozen public
    struct BinaryEncoder
    {
        @usableFromInline
        var output:BSON.Output
        @usableFromInline
        var first:Int

        @inlinable
        init(_ output:BSON.Output, first:Int)
        {
            self.output = output
            self.first = first
        }
    }
}
extension BSON.BinaryEncoder
{
    @inlinable public
    var subtype:BSON.BinarySubtype
    {
        get
        {
            .init(unchecked: self.output.destination[self.first])
        }
        set(value)
        {
            self.output.destination[self.first] = value.rawValue
        }
    }
}
extension BSON.BinaryEncoder:BSON.Encoder
{
    /// Creates a binary encoder by taking ownership the given output buffer, initializing the
    /// binary subtype to ``BSON.BinarySubtype/generic``.
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        let subtype:BSON.BinarySubtype = .generic
        let index:Int = output.destination.endIndex
        output.append(subtype.rawValue)

        self.init(output, first: index)
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.output }

    @inlinable public static
    var frame:BSON.BinaryFrame { .binary }
}
extension BSON.BinaryEncoder
{
    @inlinable public static
    func += (self:inout Self, bytes:some Sequence<UInt8>)
    {
        self.output.append(bytes)
    }

    @inlinable public mutating
    func append(_ byte:UInt8)
    {
        self.output.append(byte)
    }

    @inlinable public mutating
    func reserve(another bytes:Int)
    {
        self.output.reserve(another: bytes)
    }
}
