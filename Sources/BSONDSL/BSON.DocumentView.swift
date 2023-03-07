import BSON

extension BSON.DocumentView<[UInt8]>
{
    /// Stores the output buffer of the given document into
    /// an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ document:some BSONDSL)
    {
        self.init(slice: document.bytes)
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
