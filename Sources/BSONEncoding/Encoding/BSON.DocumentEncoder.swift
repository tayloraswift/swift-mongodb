extension BSON
{
    @frozen public
    struct DocumentEncoder<CodingKey> 
    {
        public
        var document:Document

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.document = .init(bytes: bytes)
        }
    }
}
extension BSON.DocumentEncoder:BSONDSL, BSONDSLEncodable
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension BSON.DocumentEncoder:BSONEncoder where CodingKey:RawRepresentable<String>
{
    @inlinable public mutating
    func append(_ key:CodingKey, _ value:some BSONDSLEncodable)
    {
        self.document.append(key.rawValue, with: value.encode(to:))
    }
}
