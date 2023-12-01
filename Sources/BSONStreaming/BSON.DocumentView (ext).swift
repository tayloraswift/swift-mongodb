import BSONTypes

extension BSON.DocumentView<[UInt8]>
{
    /// Stores the output buffer of the given document into
    /// an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ document:BSON.Document)
    {
        self.init(slice: document.bytes)
    }
}
extension BSON.DocumentView
{
    /// Parses this document into key-value pairs in order, yielding each key-value
    /// pair to the provided closure.
    ///
    /// Unlike ``parse``, this method does not allocate storage for the parsed key-value
    /// pairs. (But it does allocate storage to provide a ``String`` representation for
    /// each visited key.)
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the size of this document’s backing storage.
    @inlinable public
    func parse<CodingKey>(
        to decode:(_ key:CodingKey, _ value:BSON.AnyValue<Bytes.SubSequence>) throws -> ()) throws
        where CodingKey:RawRepresentable<String>
    {
        var input:BSON.Input<Bytes> = .init(self.slice)
        while let code:UInt8 = input.next()
        {
            let type:BSON.AnyType = try .init(code: code)
            let key:String = try input.parse(as: String.self)
            //  We must parse the value always, even if we are ignoring the key
            let value:BSON.AnyValue<Bytes.SubSequence> = try input.parse(variant: type)

            if let key:CodingKey = .init(rawValue: key)
            {
                try decode(key, value)
            }
        }
    }
    /// Splits this document’s inline key-value pairs into an array.
    ///
    /// Calling this convenience method is the same as calling ``parse(to:)`` and
    /// collecting the yielded key-value pairs in an array.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the size of this document’s backing storage.
    @inlinable public
    func parse<CodingKey, T>(
        _ transform:(_ key:CodingKey, _ value:BSON.AnyValue<Bytes.SubSequence>) throws -> T)
        throws -> [T]
        where CodingKey:RawRepresentable<String>
    {
        var elements:[T] = []
        try self.parse
        {
            elements.append(try transform($0, $1))
        }
        return elements
    }
}
extension BSON.DocumentView:ExpressibleByDictionaryLiteral
    where   Bytes:RangeReplaceableCollection<UInt8>,
            Bytes:RandomAccessCollection<UInt8>,
            Bytes.Index == Int
{
    /// Creates a document containing the given fields, making two passes over
    /// the list of fields in order to encode the output without reallocations.
    /// The order of the fields will be preserved.
    @inlinable public
    init(fields:some Collection<(key:BSON.Key, value:BSON.AnyValue<some RandomAccessCollection<UInt8>>)>)
    {
        let size:Int = fields.reduce(0) { $0 + 2 + $1.key.rawValue.utf8.count + $1.value.size }
        var output:BSON.Output<Bytes> = .init(capacity: size)
            output.serialize(fields: fields)

        assert(output.destination.count == size,
            "precomputed size (\(size)) does not match output size (\(output.destination.count))")

        self.init(slice: output.destination)
    }

    /// Creates a document containing a single key-value pair.
    @inlinable public
    init<Other>(key:BSON.Key, value:BSON.AnyValue<Other>)
        where Other:RandomAccessCollection<UInt8>
    {
        self.init(
            fields: CollectionOfOne<(key:BSON.Key, value:BSON.AnyValue<Other>)>.init((key, value)))
    }

    @inlinable public
    init(dictionaryLiteral:(BSON.Key, BSON.AnyValue<Bytes>)...)
    {
        self.init(fields: dictionaryLiteral)
    }
}
