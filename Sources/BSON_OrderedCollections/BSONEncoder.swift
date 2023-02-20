import BSONEncoding
import OrderedCollections

extension BSONEncoder
{
    @inlinable public
    subscript<Encodable>(key:CodingKey,
        elide elide:Bool) -> OrderedDictionary<String, Encodable>?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            if let value:OrderedDictionary<String, Encodable>, !(elide && value.isEmpty)
            {
                self.append(key, value)
            }
        }
    }
}
