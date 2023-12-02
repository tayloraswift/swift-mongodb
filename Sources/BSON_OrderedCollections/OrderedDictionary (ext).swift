import BSON
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
            (field:BSON.FieldDecoder<BSON.Key, Bytes.SubSequence>) in

            if case _? = self.updateValue(try field.decode(to: Value.self),
                forKey: field.key.rawValue)
            {
                throw BSON.DocumentKeyError<String>.duplicate(field.key.rawValue)
            }
        }
    }
}
extension OrderedDictionary:BSONDocumentEncodable, BSONEncodable
    where Key == String, Value:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        for (key, value):(Key, Value) in self.elements
        {
            bson.append(.init(rawValue: key), value)
        }
    }
}
