public
protocol BSONDocumentEncodable<CodingKeys>:BSONDSLEncodable
{
    associatedtype CodingKeys:RawRepresentable<String> & Hashable = BSON.UniversalKey

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
        field.frame(then: self.encode(to:))
    }
}
extension BSONDocumentEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.Document)
    {
        var encoder:BSON.DocumentEncoder<CodingKeys> = .init(output: bson.output)
        bson.output = .init(preallocated: [])

        self.encode(to: &encoder)
        
        bson.output = encoder.output
    }
}
