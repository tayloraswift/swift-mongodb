import BSONEncoding

public
protocol MongoFailpoint:BSONDocumentEncodable, Sendable
{
    static
    var name:String { get }
}
