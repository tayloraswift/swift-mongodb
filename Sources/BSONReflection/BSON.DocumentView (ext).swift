import BSON

extension BSON.DocumentView
{
    func description(indent:BSON.Indent) -> String
    {
        if  self.isEmpty
        {
            return "[:]"
        }
        do
        {
            var string:String = indent.level == 0 ? "{" : "\(indent){"
            try self.parse
            {
                (indent + 1).print(key: $0, value: $1, to: &string)
            }
            string += "\(indent)}"
            return string
        }
        catch
        {
            return "{ corrupted }"
        }
    }
}
extension BSON.DocumentView:CustomStringConvertible
{
    public
    var description:String { self.description(indent: "    ") }
}
extension BSON.DocumentView
{
    /// Performs a type-aware equivalence comparison by parsing each operand and recursively
    /// comparing the elements. Returns false if either operand fails to parse.
    ///
    /// Some documents that do not compare equal under byte-wise
    /// `==` comparison may compare equal under this operator, due to normalization
    /// of deprecated BSON variants. For example, a value of the deprecated `symbol` type
    /// will compare equal to a ``BSON Value.string(_:)`` value with the same contents.
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
extension BSON.DocumentView
    where   Bytes:RangeReplaceableCollection<UInt8>,
            Bytes:RandomAccessCollection<UInt8>,
            Bytes.Index == Int
{
    /// Recursively parses and re-encodes this document, and any embedded documents
    /// (and list-documents) in its elements. The keys will not be changed or re-ordered.
    @inlinable public
    func canonicalized() throws -> Self
    {
        .init(fields: try self.parse { ($0, try $1.canonicalized()) })
    }
}
