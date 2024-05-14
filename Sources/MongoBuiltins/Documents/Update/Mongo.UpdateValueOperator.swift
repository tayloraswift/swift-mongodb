extension Mongo
{
    /// A value operator is an update operator that encodes a document that can contain fields
    /// of arbitrary ``BSONEncodable`` types. It has no requirements, as it only exists to gate
    /// the subscripts of ``UpdateFieldsEncoder``.
    public
    protocol UpdateValueOperator
    {
    }
}
