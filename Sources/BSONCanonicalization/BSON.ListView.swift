import BSON

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
