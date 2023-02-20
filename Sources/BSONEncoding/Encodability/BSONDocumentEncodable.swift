
public
protocol BSONDocumentEncodable<CodingKeys>:BSONDSLEncodable
{
    associatedtype CodingKeys = String

    /// Creates a document from this instance by encoding to
    /// the encoding container parameter.
    ///
    /// The implementation may assume the encoding container is
    /// initially empty, which means implementations can simply
    /// assign assign a stored document to the `inout` binding.
    func encode(to bson:inout BSON.Document)
    /// Creates a document from this instance by encoding to
    /// the encoding container parameter, using a strongly-typed
    /// coding key type.
    ///
    /// The implementation may assume the encoding container is
    /// initially empty, which means implementations can simply
    /// assign assign a stored document to the `inout` binding.
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
}
extension BSONDocumentEncodable<String>
{
    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<String>)
    {
        self.encode(to: &bson.document)
    }
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(BSON.Document.init(
            with: self.encode(to:))))
    }
}
extension BSONDocumentEncodable where CodingKeys:RawRepresentable<String>
{
    @available(*, unavailable, message:
    """
    An encodable type with enumerated 'CodingKeys' must provide a 'DocumentEncoder' witness.
    """)
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        fatalError()
    }
    @inlinable public
    func encode(to bson:inout BSON.Document)
    {
        bson = BSON.DocumentEncoder<CodingKeys>.init(with: self.encode(to:)).document
    }
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(BSON.DocumentEncoder<CodingKeys>.init(
            with: self.encode(to:))))
    }
}
