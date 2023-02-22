import BSON

extension BSON.DocumentView:BSONView
{
    @inlinable public
    init(_ value:BSON.AnyValue<Bytes>) throws
    {
        self = try value.cast(with: \.document)
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
            let type:BSON = try .init(code: code)
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

extension BSON.DocumentView
{
    /// Performs a type-aware equivalence comparison by parsing each operand and recursively
    /// comparing the elements. Returns [`false`]() if either operand fails to parse.
    ///
    /// Some documents that do not compare equal under byte-wise
    /// `==` comparison may compare equal under this operator, due to normalization
    /// of deprecated BSON variants. For example, a value of the deprecated `symbol` type
    /// will compare equal to a `BSON//Value.string(_:)` value with the same contents.
    @inlinable public static
    func ~~ <Other>(lhs:Self, rhs:BSON.DocumentView<Other>) -> Bool
    {
        if  let lhs:[(key:BSON.Key, value:BSON.AnyValue<Bytes.SubSequence>)] =
                try? lhs.parse({ ($0, $1) }),
            let rhs:[(key:BSON.Key, value:BSON.AnyValue<Other.SubSequence>)] =
                try? rhs.parse({ ($0, $1) }),
                rhs.count == lhs.count
        {
            for (lhs, rhs):
            (
                (key:BSON.Key, value:BSON.AnyValue<Bytes.SubSequence>),
                (key:BSON.Key, value:BSON.AnyValue<Other.SubSequence>)
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
