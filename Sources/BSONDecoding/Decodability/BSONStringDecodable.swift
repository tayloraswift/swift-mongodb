/// A type that can be decoded from a BSON UTF-8 string. Javascript sources
/// count as UTF-8 strings, from the perspective of this protocol. This protocol
/// exists to allow types that also conform to ``LosslessStringConvertible``
/// to opt-in to automatic ``BSONDecodable`` conformance as well.
public
protocol BSONStringDecodable:BSONDecodable
{
    /// Initializes an instance of this type from the given UTF-8 string.
    init(bson:BSON.UTF8View<ArraySlice<UInt8>>) throws
}
extension BSONStringDecodable
{
    /// Attempts to cast the given variant value to a string, and then
    /// delegates to this type’s ``init(bson:) [3WSG]`` witness.
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        try self.init(bson: try .init(bson: bson))
    }
}
extension BSONStringDecodable where Self:LosslessStringConvertible
{
    /// Attempts to cast the given variant value to a string, and then
    /// delegates to this type’s ``LosslessStringConvertible/init(_:)`` witness.
    ///
    /// This default implementation is provided on an extension on a
    /// dedicated protocol rather than an extension on ``BSONDecodable``
    /// itself to prevent unexpected behavior for types (such as ``Double``)
    /// who implement ``LosslessStringConvertible``, but expect to be
    /// decoded from a variant value that is not a string.
    @inlinable public
    init(bson:BSON.UTF8View<ArraySlice<UInt8>>) throws
    {
        let string:String = .init(bson: bson)
        if  let value:Self = .init(string)
        {
            self = value
        }
        else
        {
            throw BSON.ValueError<String, Self>.init(invalid: string)
        }
    }
}
