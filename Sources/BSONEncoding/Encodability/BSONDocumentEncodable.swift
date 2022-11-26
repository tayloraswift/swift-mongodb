public
protocol BSONDocumentEncodable:BSONEncodable
{
    /// Creates a document from this instance by writing its
    /// fields to the encoding view parameter. The implementation
    /// may assume the encoding view is initially empty.
    func encode(to fields:inout BSON.Fields)
}
extension BSONDocumentEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(.init(with: self.encode(to:))))
    }
}
