/// A type that can be encoded to a BSON document. This protocol exists to
/// allow types that define ``CodingKey`` to encode themselves using a
/// ``BSON.DocumentEncoder``.
///
/// In general, you should *not* require this protocol if the intention is
/// simply to constrain a type parameter to a type that can only encode a
/// BSON document.
public
protocol BSONDocumentEncodable<CodingKey>:BSONEncodable
{
    associatedtype CodingKey:RawRepresentable<String> = BSON.Key

    /// Creates a document from this instance by encoding to
    /// the parameter.
    ///
    /// The implementation must not assume the encoding container
    /// is initially empty, because it may be the owner of the
    /// final output buffer.
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
}
extension BSONDocumentEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.encode(to: &field[as: BSON.DocumentEncoder<CodingKey>.self])
    }
}
