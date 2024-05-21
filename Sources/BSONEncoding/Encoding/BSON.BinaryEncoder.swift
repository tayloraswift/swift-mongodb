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
    @inlinable public mutating
    func copy(from bytes:UnsafeRawBufferPointer)
    {
        self.output.reserve(another: bytes.count)
        self.output.append(bytes)
    }

    /// Encodes the elements of the sequence to this binary encoder by densely copying each
    /// element’s raw memory representation, without any padding.
    @inlinable public mutating
    func copyDensely<Trivial>(from elements:some Sequence<Trivial>, count:Int)
    {
        self.output.reserve(another: count * MemoryLayout<Trivial>.size)

        for trivial:Trivial in elements
        {
            withUnsafeBytes(of: trivial)
            {
                self.output.append($0)
            }
        }
    }
}
