public
protocol BSONDSLEncodable
{
    /// A type that can be encoded to a BSON variant value.
    func encode(to field:inout BSON.Field)
}
extension BSONDSLEncodable where Self:BSONDSL
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(self))
    }
}
extension BSONDSLEncodable where Self:RawRepresentable, RawValue:BSONDSLEncodable
{
    /// Returns the ``encode(to:)`` witness of this type’s ``RawRepresentable.rawValue``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.rawValue.encode(to: &field)
    }
}
extension BSONDSLEncodable where Self:Sequence, Element:BSONDSLEncodable
{
    /// Encodes this sequence as a value of type ``BSON.list``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(list: .init(BSON.List<Never>.init(elements: self)))
    }
}
extension BSONDSLEncodable where Self:BinaryFloatingPoint
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(double: .init(self))
    }
}

extension Optional:BSONDSLEncodable where Wrapped:BSONDSLEncodable
{
    /// Encodes this optional as an explicit ``BSON.null``, if
    /// [`nil`]().
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        if let self:Wrapped
        {
            self.encode(to: &field)
        }
        else
        {
            field.encode(null: ())
        }
    }
}
//  We generally do *not* want dictionaries to be encodable, and dictionary
//  literal generate dictionaries by default.
extension [String: Never]:BSONDSLEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(slice: []))
    }
}
extension Array:BSONDSLEncodable where Element:BSONDSLEncodable
{
}
extension Set:BSONDSLEncodable where Element:BSONDSLEncodable
{
}
