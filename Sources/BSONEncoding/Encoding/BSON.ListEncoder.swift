extension BSON
{
    /// A type that can encode BSON list elements directly to an output buffer.
    ///
    /// Unlike ``DocumentEncoder``, which works with ``BSONDocumentEncodable``,
    /// this type currently doesn’t have a companion protocol. That’s because
    /// we currently only use it to bootstrap faster ``BSONFieldEncodable``
    /// conformances for ``Sequence``s.
    @frozen public
    struct ListEncoder
    {
        public
        var output:BSON.Output<[UInt8]>
        public
        var count:Int

        @inlinable public
        init(output:BSON.Output<[UInt8]>)
        {
            self.output = output
            self.count = 0
        }
    }
}
extension BSON.ListEncoder:BSONEncoder
{
    @inlinable public static
    var type:BSON { .list }
}
extension BSON.ListEncoder
{
    @inlinable internal mutating
    func append(with serialize:(inout BSON.Field) -> ())
    {
        serialize(&self.output[with: .init(index: self.count)])
        self.count += 1
    }
    @inlinable public mutating
    func append(_ value:some BSONFieldEncodable)
    {
        self.append(with: value.encode(to:))
    }
    /// Encodes and appends the given value if it is non-`nil`, does
    /// nothing otherwise.
    @inlinable public mutating
    func push(_ element:(some BSONFieldEncodable)?)
    {
        element.map
        {
            self.append($0)
        }
    }

    @available(*, deprecated, message: "use append(_:) for non-optional values")
    public mutating
    func push(_ element:some BSONFieldEncodable)
    {
        self.push(element as _?)
    }
}
