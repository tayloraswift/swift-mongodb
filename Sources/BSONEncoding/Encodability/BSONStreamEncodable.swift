public
protocol BSONStreamEncodable
{
    /// A type that can be encoded to a BSON variant value.
    func encode(to field:inout BSON.Field)
}
extension BSONStreamEncodable where Self:BSONStream
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(self))
    }
}
extension BSONStreamEncodable where Self:RawRepresentable, RawValue:BSONStreamEncodable
{
    /// Returns the ``encode(to:)`` witness of this type’s ``RawRepresentable.rawValue``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.rawValue.encode(to: &field)
    }
}
extension BSONStreamEncodable where Self:Sequence, Element:BSONStreamEncodable
{
    /// Encodes this sequence as a value of type ``BSON.list``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.with(BSON.ListEncoder.self)
        {
            for element:Element in self
            {
                $0.append(element)
            }
        }
    }
}
extension BSONStreamEncodable where Self:BinaryFloatingPoint
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(double: .init(self))
    }
}

extension Optional:BSONStreamEncodable where Wrapped:BSONStreamEncodable
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
extension [String: Never]:BSONStreamEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(slice: []))
    }
}
extension Array:BSONStreamEncodable where Element:BSONStreamEncodable
{
}
extension Set:BSONStreamEncodable where Element:BSONStreamEncodable
{
}
