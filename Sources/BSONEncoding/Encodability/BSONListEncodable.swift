/// A type that can be encoded to a BSON list. This protocol exists to
/// allow types that also conform to ``Sequence`` to opt-in to automatic
/// ``BSONEncodable`` conformance as well.
///
/// In general, you should *not* require this protocol if the intention is
/// simply to constrain a type parameter to a type that can only encode a
/// BSON list. For example, ``Array`` always encodes itself as a list, but
/// it does not conform to this protocol.
///
/// >   Tip:
///     Not every type that *can* be ``BSONListEncodable`` *should* be
///     ``BSONListEncodable``. For example, ``Set`` is a ``Sequence``, but
///     it does not encode itself deterministically. So encoding instances
///     of ``Set`` directly is usually not what you want.
public
protocol BSONListEncodable:BSONEncodable
{
    /// Populates a list from this instance by encoding to the parameter.
    ///
    /// The implementation must not assume the encoding container is initially empty, because it
    /// may be the owner of the final output buffer.
    func encode(to bson:inout BSON.ListEncoder)
}
extension BSONListEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.encode(to: &field[as: BSON.ListEncoder.self])
    }
}
extension BSONListEncodable where Self:Sequence, Element:BSONEncodable
{
    /// Encodes this sequence as a value of type ``BSON.AnyType/list``.
    @inlinable public
    func encode(to bson:inout BSON.ListEncoder)
    {
        for element:Element in self
        {
            bson.append(element)
        }
    }
}
