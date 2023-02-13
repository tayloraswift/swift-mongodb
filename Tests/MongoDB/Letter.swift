import BSONDecoding
import BSONEncoding

struct Letter:Hashable, Sendable
{
    let id:Unicode.Scalar
}
extension Letter:ExpressibleByUnicodeScalarLiteral
{
    init(unicodeScalarLiteral:Unicode.Scalar)
    {
        self.init(id: unicodeScalarLiteral)
    }
}
extension Letter:BSONEncodable, BSONDocumentEncodable
{
    func encode(to bson:inout BSON.Fields)
    {
        bson["_id"] = self.id
    }
}
extension Letter:BSONDecodable, BSONDictionaryDecodable
{
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson["_id"].decode(to: Unicode.Scalar.self))
    }
}
extension Letter:CustomStringConvertible
{
    var description:String
    {
        """
        {_id: '\(self.id)'}
        """
    }
}
