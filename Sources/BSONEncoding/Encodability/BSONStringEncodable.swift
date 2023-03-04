/// A type that can be encoded to a BSON UTF-8 string. This protocol
/// exists to allow types that also conform to ``LosslessStringConvertible``
/// to opt-in to automatic ``BSONEncodable`` conformance as well.
public
protocol BSONStringEncodable:BSONEncodable
{
    /// Converts an instance of this type to a string. This requirement
    /// restates its counterpart in ``LosslessStringConvertible`` if
    /// [`Self`]() also conforms to it.
    var description:String { get }
}
extension BSONStringEncodable
{
    /// Encodes the ``description`` of this instance as a BSON UTF-8 string.
    ///
    /// This default implementation is provided on an extension on a
    /// dedicated protocol rather than an extension on ``BSONEncodable``
    /// itself to prevent unexpected behavior for types (such as ``Double``)
    /// who implement ``LosslessStringConvertible``, but expect to be
    /// encoded as something besides a UTF-8 string.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.description.encode(to: &field)
    }
}
