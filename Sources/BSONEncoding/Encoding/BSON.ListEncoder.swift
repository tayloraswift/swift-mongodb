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
    var type:BSON.AnyType { .list }
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
    @inlinable public mutating
    func append(_ value:some BSONEncodable)
    {
        self.append(with: value.encode(to:))
    }
    /// Encodes and appends the given value if it is non-`nil`, does
    /// nothing otherwise.
    @inlinable public mutating
    func push(_ element:(some BSONEncodable)?)
    {
        element.map
        {
            self.append($0)
        }
    }
    @available(*, deprecated, message: "use append(_:) for non-optional values")
    public mutating
    func push(_ element:some BSONEncodable)
    {
        self.push(element as _?)
    }
}
extension BSON.ListEncoder
{
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
