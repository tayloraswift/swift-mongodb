import BSONSchema
import BSONUnions
import OrderedCollections

extension OrderedDictionary:BSONDocumentDecodable, BSONDecodable
    where Key == String, Value:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.Document<Bytes>) throws
    {
        self.init()
        try bson.parse
        {
            if case _? = self.updateValue(try $0.decode(to: Value.self), forKey: $0.key)
            {
                throw BSON.DictionaryKeyError.duplicate($0.key)
            }
        }
    }
}
extension OrderedDictionary:BSONDocumentEncodable, BSONEncodable
    where Key == String, Value:BSONEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        for (key, value):(Key, Value) in self.elements
        {
            bson[key] = value
        }
    }
}
