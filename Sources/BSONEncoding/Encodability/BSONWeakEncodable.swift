public
protocol BSONWeakEncodable
{
    /// A type that can be encoded to a BSON variant value.
    func encode(to field:inout BSON.Field)
}

extension BSONWeakEncodable where Self:BSONRepresentable, BSONRepresentation:BSONWeakEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.bson.encode(to: &field)
    }
}

extension BSONWeakEncodable where Self:RawRepresentable, RawValue:BSONWeakEncodable
{
    /// Returns the ``encode(to:)`` witness of this type’s ``RawRepresentable.rawValue``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.rawValue.encode(to: &field)
    }
}

extension Array:BSONWeakEncodable where Element:BSONWeakEncodable
{
    /// Encodes this array as a value of type ``BSON.list``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        {
            for element:Element in self
            {
                $0.append(element)
            }
        } (&field[as: BSON.ListEncoder.self])
    }
}
extension Optional:BSONWeakEncodable where Wrapped:BSONWeakEncodable
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
//  literals generate dictionaries by default.
extension [String: Never]:BSONWeakEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(slice: []))
    }
}
