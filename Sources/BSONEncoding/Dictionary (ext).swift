/// We generally do *not* want dictionaries to be ``BSONEncodable``,
/// and dictionary literals generate dictionaries by default.
extension [String: Never]:BSONEncodable
{
    /// Encodes this dictionary as an empty document.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(document: .init(slice: []))
    }
}
