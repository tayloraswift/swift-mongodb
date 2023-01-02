import BSONSchema
import BSONUnions
import OrderedCollections

extension OrderedDictionary:BSONDocumentDecodable, BSONDecodable
    where Key == String, Value:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.Document<Bytes>) throws
    {
        let fields:[(key:String, value:AnyBSON<Bytes.SubSequence>)] = try bson.parse()
        self.init(minimumCapacity: fields.count)
        for (key, value):(String, AnyBSON<Bytes.SubSequence>) in fields
        {
            if case _? = self.updateValue(try .init(bson: value), forKey: key)
            {
                throw BSON.DictionaryKeyError.duplicate(key)
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
