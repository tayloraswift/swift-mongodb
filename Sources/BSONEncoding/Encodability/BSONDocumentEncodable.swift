public
protocol BSONDocumentEncodable<CodingKeys>:BSONEncodable
{
    associatedtype CodingKeys:RawRepresentable<String> & Hashable = BSON.Key

    /// Creates a document from this instance by encoding to
    /// the parameter.
    ///
    /// The implementation must not assume the encoding container
    /// is initially empty, because it may be the owner of the
    /// final output buffer.
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
}
extension BSONDocumentEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(with: self.encode(to:))
    }
}
