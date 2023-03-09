public
protocol BSONFieldEncodable
{
    /// A type that can be encoded to a BSON variant value.
    func encode(to field:inout BSON.Field)
}

extension BSONFieldEncodable where Self:BSONRepresentable, BSONRepresentation:BSONFieldEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.bson.encode(to: &field)
    }
}
extension BSONFieldEncodable where Self:RawRepresentable, RawValue:BSONFieldEncodable
{
    /// Returns the ``encode(to:)`` witness of this type’s ``RawRepresentable.rawValue``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.rawValue.encode(to: &field)
    }
}
extension BSONFieldEncodable where Self:Sequence, Element:BSONFieldEncodable
{
    /// Encodes this sequence as a value of type ``BSON.list``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(as: BSON.ListEncoder.self)
        {
            for element:Element in self
            {
                $0.append(element)
            }
        }
    }
}
extension BSONFieldEncodable where Self:BinaryFloatingPoint
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(double: .init(self))
    }
}

extension Optional:BSONFieldEncodable where Wrapped:BSONFieldEncodable
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
extension [String: Never]:BSONFieldEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(slice: []))
    }
}
extension Array:BSONFieldEncodable where Element:BSONFieldEncodable
{
}
extension Set:BSONFieldEncodable where Element:BSONFieldEncodable
{
}
