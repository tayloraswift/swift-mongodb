import BSON

extension BSON.ListView:BSONView
{
    @inlinable public
    init(_ value:BSON.AnyValue<Bytes>) throws
    {
        self = try value.cast(with: \.list)
    }
}
extension BSON.ListView
{
    /// Parses this list into key-value pairs in order, yielding each value to the
    /// provided closure. Parsing a list is slightly faster than parsing a general 
    /// ``DocumentView``, because this method ignores the document keys.
    ///
    /// This method does *not* perform any key validation.
    ///
    /// Unlike ``parse``, this method does not allocate storage for the parsed
    /// elements.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the size of this list’s backing storage.
    @inlinable public
    func parse(to decode:(_ element:BSON.AnyValue<Bytes.SubSequence>) throws -> ()) throws
    {
        var input:BSON.Input<Bytes> = .init(self.slice)
        while let code:UInt8 = input.next()
        {
            let type:BSON = try .init(code: code)
            try input.parse(through: 0x00)
            try decode(try input.parse(variant: type))
        }
    }
    @inlinable public
    func parse<T>(
        _ transform:(_ element:BSON.AnyValue<Bytes.SubSequence>) throws -> T) throws -> [T]
    {
        var elements:[T] = []
        try self.parse
        {
            elements.append(try transform($0))
        }
        return elements
    }
    /// Splits this list’s inline key-value pairs into an array containing the
    /// values only. Parsing a list is slightly faster than parsing a general 
    /// ``DocumentView``, because this method ignores the document keys.
    ///
    /// This method does *not* perform any key validation.
    ///
    /// Calling this convenience method is the same as calling ``parse(to:)`` and
    /// collecting the yielded elements in an array.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the size of this list’s backing storage.
    @inlinable public
    func parse() throws -> [BSON.AnyValue<Bytes.SubSequence>]
    {
        try self.parse { $0 }
    }
}
extension BSON.ListView
{
    /// Performs a type-aware equivalence comparison by parsing each operand and recursively
    /// comparing the elements, ignoring list key names. Returns [`false`]() if either
    /// operand fails to parse.
    ///
    /// Some embedded documents that do not compare equal under byte-wise
    /// `==` comparison may also compare equal under this operator, due to normalization
    /// of deprecated BSON variants. For example, a value of the deprecated `symbol` type
    /// will compare equal to a `BSON//Value.string(_:)` value with the same contents.
    @inlinable public static
    func ~~ <Other>(lhs:Self, rhs:BSON.ListView<Other>) -> Bool
    {
        if  let lhs:[BSON.AnyValue<Bytes.SubSequence>] = try? lhs.parse(),
            let rhs:[BSON.AnyValue<Other.SubSequence>] = try? rhs.parse(),
                rhs.count == lhs.count
        {
            for (lhs, rhs):(BSON.AnyValue<Bytes.SubSequence>, BSON.AnyValue<Other.SubSequence>) in
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
