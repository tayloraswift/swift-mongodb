import BSONEncoding

public
protocol MongoEncodable:BSONDocumentEncodable, Sendable
{
}
