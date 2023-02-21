import BSON

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
