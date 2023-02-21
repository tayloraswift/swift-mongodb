extension BSON.Document
{
    @inlinable public
    init<Encodable>(fields:some Sequence<(key:BSON.Key, value:Encodable)>)
        where Encodable:BSONEncodable
    {
        self.init()
        for (key, value):(CodingKey, Encodable) in fields
        {
            self.append(key, value)
        }
    }
}
extension BSON.Document:BSONBuilder
{
    @inlinable public mutating
    func append(_ key:BSON.Key, _ value:some BSONDSLEncodable)
    {
        self.append(key, with: value.encode(to:))
    }
}
extension BSON.Document:BSONEncodable
{
}
