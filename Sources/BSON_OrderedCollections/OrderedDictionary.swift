import BSONDecoding
import BSONEncoding
import BSONView
import OrderedCollections

extension OrderedDictionary:BSONDocumentViewDecodable, BSONDecodable
    where Key == String, Value:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentView<Bytes>) throws
    {
        self.init()
        try bson.parse
        {
            (field:BSON.ExplicitField<BSON.Key, Bytes.SubSequence>) in

            if case _? = self.updateValue(try field.decode(to: Value.self),
                forKey: field.key.rawValue)
            {
                throw BSON.DocumentKeyError<String>.duplicate(field.key.rawValue)
            }
        }
    }
}
extension OrderedDictionary:BSONStreamEncodable
    where Key == String, Value:BSONStreamEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.with(BSON.DocumentEncoder<BSON.Key>.self, do: self.encode(to:))
    }
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        for (key, value):(Key, Value) in self.elements
        {
            bson.append(.init(rawValue: key), value)
        }
    }
}
extension OrderedDictionary:BSONDocumentEncodable, BSONEncodable
    where Key == String, Value:BSONEncodable
{
}
