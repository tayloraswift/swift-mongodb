extension BSON
{
    /// A type that can encode BSON list elements directly to an output buffer.
    ///
    /// Like ``DocumentEncoder``, which works with ``BSONDocumentEncodable``,
    /// this type has its own companion protocol ``BSONListEncodable``, which is used to
    /// bootstrap faster ``BSONEncodable`` conformances for ``Sequence``s.
    @frozen public
    struct ListEncoder
    {
        @usableFromInline
        var output:BSON.Output
        @usableFromInline
        var count:Int

        @inlinable public
        init(_ output:BSON.Output)
        {
            self.output = output
            self.count = 0
        }
    }
}
extension BSON.ListEncoder:BSON.Encoder
{
    @inlinable public consuming
    func move() -> BSON.Output { self.output }

    @inlinable public static
    var frame:BSON.DocumentFrame { .list }
}
extension BSON.ListEncoder
{
    @inlinable public mutating
    func append(with encode:(inout BSON.FieldEncoder) -> ())
    {
        encode(&self.output[with: .init(index: self.count)])
        self.count += 1
    }
}
extension BSON.ListEncoder
{
    @inlinable mutating
    func append(_ value:some BSONEncodable)
    {
        self.append(with: value.encode(to:))
    }
}
extension BSON.ListEncoder
{
    /// Appends a value to the list if non-nil, does nothing otherwise.
    ///
    /// Why a subscript and not an `append` method? Because we often want to optionally append a
    /// value while building a list, and the subscript syntax is more convenient for that.
    @inlinable public
    subscript<Encodable>(_:(Index) -> Void) -> Encodable? where Encodable:BSONEncodable
    {
        get { nil }
        set (value)
        {
            if  let value:Encodable
            {
                self.append(value)
            }
        }
    }

    @inlinable public mutating
    func callAsFunction(_ yield:(inout BSON.ListEncoder) -> ())
    {
        self.append { yield(&$0[as: BSON.ListEncoder.self]) }
    }
    @inlinable public mutating
    func callAsFunction<CodingKey>(_:CodingKey.Type = CodingKey.self,
        _ yield:(inout BSON.DocumentEncoder<CodingKey>) -> ())
    {
        self.append { yield(&$0[as: BSON.DocumentEncoder<CodingKey>.self]) }
    }
}
