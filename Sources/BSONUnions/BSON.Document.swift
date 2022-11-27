import BSON

extension BSON.Document
{
    @inlinable public
    init(_ value:AnyBSON<Bytes>) throws
    {
        self = try value.cast(with: \.document)
    }
}
extension BSON.Document
{
    /// Splits this document’s inline key-value pairs into an array.
    ///
    /// >   Complexity: O(*n*), where *n* is the size of this document’s backing storage.
    @inlinable public
    func parse() throws -> [(key:String, value:AnyBSON<Bytes.SubSequence>)]
    {
        var input:BSON.Input<Bytes> = .init(self.bytes)
        var items:[(key:String, value:AnyBSON<Bytes.SubSequence>)] = []
        while let code:UInt8 = input.next()
        {
            let type:BSON = try .init(code: code)
            let key:String = try input.parse(as: String.self)
            items.append((key, try input.parse(variant: type)))
        }
        return items
    }
}
extension BSON.Document:ExpressibleByDictionaryLiteral 
    where Bytes:RangeReplaceableCollection<UInt8>
{
    /// Creates a document containing the given fields, making two passes over
    /// the list of fields in order to encode the output without reallocations.
    /// The order of the fields will be preserved.
    @inlinable public
    init(fields:some Collection<(key:String, value:AnyBSON<some RandomAccessCollection<UInt8>>)>)
    {
        let size:Int = fields.reduce(0) { $0 + 2 + $1.key.utf8.count + $1.value.size }
        var output:BSON.Output<Bytes> = .init(capacity: size)
            output.serialize(fields: fields)
        
        assert(output.destination.count == size,
            "precomputed size (\(size)) does not match output size (\(output.destination.count))")

        self.init(bytes: output.destination)
    }

    /// Creates a document containing a single key-value pair.
    @inlinable public
    init<Other>(key:String, value:AnyBSON<Other>)
        where Other:RandomAccessCollection<UInt8>
    {
        self.init(fields: CollectionOfOne<(key:String, value:AnyBSON<Other>)>.init((key, value)))
    }

    @inlinable public
    init(dictionaryLiteral:(String, AnyBSON<Bytes>)...)
    {
        self.init(fields: dictionaryLiteral)
    }
    /// Recursively parses and re-encodes this document, and any embedded documents
    /// (and tuple-documents) in its elements. The keys will not be changed or re-ordered.
    @inlinable public
    func canonicalized() throws -> Self
    {
        .init(fields: try self.parse().map { ($0.key, try $0.value.canonicalized()) })
    }
}
extension BSON.Document
{
    /// Performs a type-aware equivalence comparison by parsing each operand and recursively
    /// comparing the elements. Returns [`false`]() if either operand fails to parse.
    ///
    /// Some documents that do not compare equal under byte-wise
    /// `==` comparison may compare equal under this operator, due to normalization
    /// of deprecated BSON variants. For example, a value of the deprecated `symbol` type
    /// will compare equal to a `BSON//Value.string(_:)` value with the same contents.
    @inlinable public static
    func ~~ <Other>(lhs:Self, rhs:BSON.Document<Other>) -> Bool
    {
        if  let lhs:[(key:String, value:AnyBSON<Bytes.SubSequence>)] = try? lhs.parse(),
            let rhs:[(key:String, value:AnyBSON<Other.SubSequence>)] = try? rhs.parse(),
                rhs.count == lhs.count
        {
            for (lhs, rhs):
            (
                (key:String, value:AnyBSON<Bytes.SubSequence>),
                (key:String, value:AnyBSON<Other.SubSequence>)
            )
            in zip(lhs, rhs)
            {
                guard   lhs.key   ==  rhs.key,
                        lhs.value ~~ rhs.value
                else
                {
                    return false
                }
            }
            return true
        }
        else
        {
            return false
        }
    }
}
