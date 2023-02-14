public
protocol BSONDocumentEncodable:BSONDSLEncodable
{
    /// Creates a document from this instance by encoding to
    /// the encoding container parameter. The implementation
    /// may assume the encoding container is initially empty.
    func encode(to document:inout BSON.Document)
}
extension BSONDocumentEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(BSON.Document.init(with: self.encode(to:))))
    }
}
