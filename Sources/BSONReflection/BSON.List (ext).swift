import BSON

extension BSON.List
{
    func description(indent:BSON.Indent) -> String
    {
        self.isEmpty ? "[]" : BSON.Document.init(list: self).description(indent: indent)
    }
}
extension BSON.List:CustomStringConvertible
{
    public
    var description:String { self.description(indent: "    ") }
}
extension BSON.List
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
    func ~~ (lhs:Self, rhs:Self) -> Bool
    {
        if  let lhs:[BSON.AnyValue] = try? lhs.parse(),
            let rhs:[BSON.AnyValue] = try? rhs.parse(),
                rhs.count == lhs.count
        {
            for (lhs, rhs):(BSON.AnyValue, BSON.AnyValue) in zip(lhs, rhs)
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
extension BSON.List
{
    /// Recursively parses and re-encodes this list-document, and any embedded documents
    /// (and list-documents) in its elements. The ordinal keys will be regenerated.
    @inlinable public
    func canonicalized() throws -> Self
    {
        .init(elements: try self.parse { try $0.canonicalized() })
    }
}
