import BSON
import OrderedCollections

extension OrderedDictionary:BSONDocumentViewDecodable, BSONDecodable
    where Key == BSON.Key, Value:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentView<Bytes>) throws
    {
        self.init()
        try bson.parse
        {
            (field:BSON.FieldDecoder<BSON.Key, Bytes.SubSequence>) in

            if case _? = self.updateValue(try field.decode(to: Value.self),
                forKey: field.key)
            {
                throw BSON.DocumentKeyError<BSON.Key>.duplicate(field.key)
            }
        }
    }
}
extension OrderedDictionary:BSONDocumentEncodable, BSONEncodable
    where Key == BSON.Key, Value:BSONEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        for (key, value):(Key, Value) in self.elements
        {
            bson[key] = value
        }
    }
}
