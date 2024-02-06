import BSON
import OrderedCollections

extension OrderedDictionary:BSONDecodable where Key == BSON.Key, Value:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        try self.init(bson: try .init(bson: consume bson))
    }
    @inlinable public
    init(bson:BSON.Document) throws
    {
        self.init()
        try bson.parse
        {
            (field:BSON.FieldDecoder<BSON.Key>) in

            if  case _? = self.updateValue(try field.decode(to: Value.self),
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
