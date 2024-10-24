import BSON
import MongoQL

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
extension Letter:Mongo.MasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case id = "_id"
    }
}
extension Letter:BSONEncodable, BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
    }
}
extension Letter:BSONDecodable, BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(to: Unicode.Scalar.self))
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
