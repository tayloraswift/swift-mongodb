import BSON

extension BSON.ListView
{
    func description(indent:BSON.Indent) -> String
    {
        self.isEmpty ? "[]" : self.document.description(indent: indent)
    }
}
extension BSON.ListView:CustomStringConvertible
{
    public
    var description:String { self.description(indent: "    ") }
}
extension BSON.ListView
{
    /// Performs a type-aware equivalence comparison by parsing each operand and recursively
    /// comparing the elements, ignoring list key names. Returns `false` if either
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
extension BSON.ListView
    where   Bytes:RangeReplaceableCollection<UInt8>,
            Bytes:RandomAccessCollection<UInt8>,
            Bytes.Index == Int
{
    /// Recursively parses and re-encodes this list-document, and any embedded documents
    /// (and list-documents) in its elements. The ordinal keys will be regenerated.
    @inlinable public
    func canonicalized() throws -> Self
    {
        .init(elements: try self.parse { try $0.canonicalized() })
    }
}
