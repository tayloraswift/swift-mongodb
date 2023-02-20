extension BSON.Document:BSONEncoder
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
