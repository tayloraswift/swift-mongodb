import BSON

extension BSON.Tuple
{
    @inlinable public
    init(_ value:AnyBSON<Bytes>) throws
    {
        self = try value.cast(with: \.tuple)
    }
}
extension BSON.Tuple
{
    /// Splits this tuple’s inline key-value pairs into an array containing the
    /// values only. Parsing a tuple is slightly faster than parsing a general 
    /// ``Document``, because this method ignores the document keys.
    ///
    /// This method does *not* perform any key validation.
    ///
    /// >   Complexity: O(*n*), where *n* is the size of this tuple’s backing storage.
    @inlinable public
    func parse() throws -> [AnyBSON<Bytes.SubSequence>]
    {
        var input:BSON.Input<Bytes> = .init(self.bytes)
        var elements:[AnyBSON<Bytes.SubSequence>] = []
        while let code:UInt8 = input.next()
        {
            let type:BSON = try .init(code: code)
            try input.parse(through: 0x00)
            elements.append(try input.parse(variant: type))
        }
        return elements
    }
}
extension BSON.Tuple:ExpressibleByArrayLiteral
    where Bytes:RangeReplaceableCollection<UInt8>
{
    /// Creates a tuple-document containing the given elements.
    @inlinable public
    init(elements:some Sequence<AnyBSON<some RandomAccessCollection<UInt8>>>)
    {
        // we do need to precompute the ordinal keys, so we know the total length
        // of the document.
        let document:BSON.Document<Bytes> = .init(fields: elements.enumerated().map
        {
            ($0.0.description, $0.1)
        })
        self.init(bytes: document.bytes)
    }

    @inlinable public 
    init(arrayLiteral:AnyBSON<Bytes>...)
    {
        self.init(elements: arrayLiteral)
    }

    /// Recursively parses and re-encodes this tuple-document, and any embedded documents
    /// (and tuple-documents) in its elements. The ordinal keys will be regenerated.
    @inlinable public
    func canonicalized() throws -> Self
    {
        .init(elements: try self.parse().map { try $0.canonicalized() })
    }
}
extension BSON.Tuple
{
    /// Performs a type-aware equivalence  comparison by parsing each operand and recursively
    /// comparing the elements, ignoring tuple key names. Returns [`false`]() if either
    /// operand fails to parse.
    ///
    /// Some embedded documents that do not compare equal under byte-wise
    /// `==` comparison may also compare equal under this operator, due to normalization
    /// of deprecated BSON variants. For example, a value of the deprecated `symbol` type
    /// will compare equal to a `BSON//Value.string(_:)` value with the same contents.
    @inlinable public static
    func ~~ <Other>(lhs:Self, rhs:BSON.Tuple<Other>) -> Bool
    {
        if  let lhs:[AnyBSON<Bytes.SubSequence>] = try? lhs.parse(),
            let rhs:[AnyBSON<Other.SubSequence>] = try? rhs.parse(),
                rhs.count == lhs.count
        {
            for (lhs, rhs):(AnyBSON<Bytes.SubSequence>, AnyBSON<Other.SubSequence>) in
                zip(lhs, rhs)
            {
                guard lhs ~~ rhs
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
