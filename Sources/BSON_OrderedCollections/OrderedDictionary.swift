import BSONDecoding
import BSONEncoding
import BSONUnions
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
            if case _? = self.updateValue(try $0.decode(to: Value.self), forKey: $0.key)
            {
                throw BSON.DocumentKeyError<String>.duplicate($0.key)
            }
        }
    }
}
extension OrderedDictionary:BSONDSLEncodable
    where Key == String, Value:BSONDSLEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.frame(then: self.encode(to:))
    }
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.UniversalKey>)
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
