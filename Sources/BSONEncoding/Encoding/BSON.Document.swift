extension BSON.Document
{
    @inlinable public
    init<Encodable>(fields:some Sequence<(key:String, value:Encodable)>)
        where Encodable:BSONEncodable
    {
        self.init()
        for (key, value):(String, Encodable) in fields
        {
            self.append(key, value)
        }
    }
}
extension BSON.Document:BSONBuilder
{
    @inlinable public mutating
    func append(_ key:String, _ value:some BSONDSLEncodable)
    {
        self.append(key, with: value.encode(to:))
    }
}
extension BSON.Document:BSONEncodable
{
}
