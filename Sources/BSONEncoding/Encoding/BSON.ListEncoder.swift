extension BSON
{
    /// A type that can encode BSON list elements directly to an output buffer.
    ///
    /// Unlike ``DocumentEncoder``, which works with ``BSONDocumentEncodable``,
    /// this type currently doesn’t have a companion protocol. That’s because
    /// we currently only use it to bootstrap faster ``BSONWeakEncodable``
    /// conformances for ``Sequence``s.
    @frozen public
    struct ListEncoder
    {
        @usableFromInline internal
        var output:BSON.Output<[UInt8]>
        @usableFromInline internal
        var count:Int

        @inlinable public
        init(_ output:BSON.Output<[UInt8]>)
        {
            self.output = output
            self.count = 0
        }
    }
}
extension BSON.ListEncoder:BSONEncoder
{
    @inlinable public consuming
    func move() -> BSON.Output<[UInt8]> { self.output }

    @inlinable public static
    var type:BSON.AnyType { .list }
}
extension BSON.ListEncoder
{
    @inlinable public mutating
    func append(with encode:(inout BSON.Field) -> ())
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
    func append(with encode:(inout BSON.ListEncoder) -> ())
    {
        self.append { encode(&$0[as: BSON.ListEncoder.self]) }
    }
    @inlinable public mutating
    func append(with encode:(inout BSON.DocumentEncoder<BSON.Key>) -> ())
    {
        self.append { encode(&$0[as: BSON.DocumentEncoder<BSON.Key>.self]) }
    }
    @inlinable public mutating
    func append<CodingKey>(using _:CodingKey.Type = CodingKey.self,
        with encode:(inout BSON.DocumentEncoder<CodingKey>) -> ())
    {
        self.append { encode(&$0[as: BSON.DocumentEncoder<CodingKey>.self]) }
    }
}
