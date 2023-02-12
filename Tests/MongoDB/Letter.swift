import BSONDecoding
import BSONEncoding
import MongoSchema

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
extension Letter:MongoEncodable
{
    func encode(to bson:inout BSON.Fields)
    {
        bson["_id"] = self.id
    }
}
extension Letter:MongoDecodable
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
